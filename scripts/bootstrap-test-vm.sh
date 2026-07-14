#!/usr/bin/env bash
# Bootstraps a clean throwaway QEMU/KVM VM and installs the `vm-test` flake
# target onto it — automates everything done by hand while getting KVM/WSL2
# working: UEFI firmware, bridged libvirt networking (WSL2 mirrored-mode
# breaks the default network's DHCP, so it must run with DHCP/DNS disabled —
# see ensure_default_network), live-ISO network bring-up, disk partitioning,
# and nixos-install. Run from anywhere; only needs virsh/qemu tooling and an
# SSH agent holding a key authorized for git@github.com:srkn0/nixbase.git.
set -euo pipefail

VM_NAME="${VM_NAME:-nixos-test}"
VM_MEMORY_MB="${VM_MEMORY_MB:-4096}"
VM_VCPUS="${VM_VCPUS:-2}"
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
DISK_SIZE_GB="${DISK_SIZE_GB:-20}"
ISO_PATH="${ISO_PATH:-$HOME/vm-isos/nixos-minimal-26.05.4808.569d57850992-x86_64-linux.iso}"
GITHUB_USER="${GITHUB_USER:-srkn0}"
REPO_URL="${REPO_URL:-git@github.com:srkn0/nixbase.git}"
FLAKE_TARGET="${FLAKE_TARGET:-vm-test}"
STATIC_IP="192.168.122.10"
GATEWAY_IP="192.168.122.1"
GUEST_IFACE="ens3"
SSH_ALIAS="nixos-test"
SSH_KEY="$HOME/.ssh/id_ed25519"

log() { echo ">>> $*"; }

# --- keystroke automation for the pre-network live-ISO console ---------
vm_type() {
  local text="$1" i char keyname
  for (( i=0; i<${#text}; i++ )); do
    char="${text:$i:1}"
    case "$char" in
      [a-z]) keyname="KEY_${char^^}" ;;
      [0-9]) keyname="KEY_${char}" ;;
      ' ') keyname="KEY_SPACE" ;;
      '.') keyname="KEY_DOT" ;;
      '/') keyname="KEY_SLASH" ;;
      '-') keyname="KEY_MINUS" ;;
      *) log "WARN vm_type: unsupported char '$char', skipping"; continue ;;
    esac
    virsh -c qemu:///system send-key "$VM_NAME" --keycode "$keyname" >/dev/null
    sleep 0.03
  done
}
vm_enter() { virsh -c qemu:///system send-key "$VM_NAME" --keycode KEY_ENTER >/dev/null; }
vm_line()  { vm_type "$1"; vm_enter; }

ssh_vm() { ssh -o ConnectTimeout=5 "$SSH_ALIAS" "$@"; }

# --- prerequisites -------------------------------------------------------

ensure_default_network() {
  # WSL2 Mirrored networking mode syncs Windows' excluded port ranges into
  # the guest netns, so dnsmasq can never bind :67 (DHCP) on the libvirt
  # "default" network. Fix is one-time and host-wide: disable dhcp+dns on
  # the network so libvirt never spawns dnsmasq for it, just NAT+bridge.
  if virsh -c qemu:///system net-dumpxml default 2>/dev/null | grep -q "<dhcp>"; then
    log "default network still has DHCP enabled — disabling (WSL2 mirrored-mode workaround)"
    virsh -c qemu:///system net-destroy default 2>/dev/null || true
    local netxml
    netxml="$(mktemp)"
    cat > "$netxml" <<'EOF'
<network>
  <name>default</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <dns enable='no'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF
    virsh -c qemu:///system net-define "$netxml"
    rm -f "$netxml"
  fi
  virsh -c qemu:///system net-list --all | grep -q "default *active" \
    || virsh -c qemu:///system net-start default
}

setup_ssh_config() {
  grep -q "^Host ${SSH_ALIAS}\$" "$HOME/.ssh/config" 2>/dev/null && return
  log "adding SSH config entry for $SSH_ALIAS"
  cat >> "$HOME/.ssh/config" <<EOF

Host ${SSH_ALIAS}
    HostName ${STATIC_IP}
    User nixos
    ForwardAgent yes
    StrictHostKeyChecking accept-new
    IdentityFile ${SSH_KEY}
EOF
  chmod 600 "$HOME/.ssh/config"
}

# --- VM lifecycle ----------------------------------------------------------

# libvirt-qemu (the unprivileged qemu process user) can't traverse a normal
# $HOME (0750), so any ISO living there fails with a silent-ish "Permission
# denied" from qemu itself. Stage it under the libvirt images pool instead,
# which is 0711 (world-traversable) with libvirt-qemu-readable files.
ensure_iso_accessible() {
  local pool_dir="/var/lib/libvirt/images"
  local staged="${pool_dir}/$(basename "$ISO_PATH")"
  if [[ "$ISO_PATH" != "$pool_dir"/* ]]; then
    if [ ! -f "$staged" ]; then
      log "staging ISO into $pool_dir (libvirt-qemu can't read \$HOME)"
      sudo cp "$ISO_PATH" "$staged"
      sudo chmod 644 "$staged"
    fi
    ISO_PATH="$staged"
  fi
}

recreate_vm() {
  log "destroying/undefining any existing $VM_NAME"
  virsh -c qemu:///system destroy "$VM_NAME" >/dev/null 2>&1 || true
  virsh -c qemu:///system undefine "$VM_NAME" --nvram >/dev/null 2>&1 || true
  sudo rm -f "$DISK_PATH"

  log "creating $VM_NAME (UEFI, bridged network, ${DISK_SIZE_GB}G disk)"
  virt-install \
    --connect qemu:///system \
    --name "$VM_NAME" \
    --memory "$VM_MEMORY_MB" \
    --vcpus "$VM_VCPUS" \
    --cpu host-passthrough \
    --boot uefi \
    --disk "path=${DISK_PATH},size=${DISK_SIZE_GB}" \
    --cdrom "$ISO_PATH" \
    --os-variant generic \
    --network network=default,model=virtio \
    --graphics spice \
    --video qxl \
    --noautoconsole
}

wait_for_live_shell() {
  log "waiting for live ISO to boot"
  sleep 35
}

bring_up_live_network() {
  log "configuring static IP on the live ISO (blind keystrokes)"
  # Priming keystroke: boot/auto-login/MOTD can still be settling even after
  # the sleep above, and keystrokes typed during that transition get eaten
  # or land mid-line. A throwaway Enter (plus a beat to let it land) flushes
  # that before we send anything that actually matters.
  vm_enter
  sleep 2
  vm_line "sudo nmcli connection add type ethernet ifname ${GUEST_IFACE} con-name static-test ipv4.method manual ipv4.addresses ${STATIC_IP}/24 ipv4.gateway ${GATEWAY_IP} ipv4.dns 1.1.1.1 connection.autoconnect yes"
  sleep 2
  vm_line "sudo nmcli connection up static-test"
  sleep 2
  for _ in $(seq 1 10); do
    ping -c1 -W1 "$STATIC_IP" >/dev/null 2>&1 && { log "network is up"; return; }
    sleep 2
  done
  echo "ERROR: guest never came up on $STATIC_IP — check virt-manager console" >&2
  exit 1
}

set_live_password_and_key() {
  log "setting live-ISO nixos password + installing SSH key"
  vm_line "sudo passwd nixos"
  sleep 1.5
  vm_line "123"
  sleep 1
  vm_line "123"
  sleep 1.5
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$STATIC_IP" >/dev/null 2>&1 || true
  sshpass -p '123' ssh-copy-id -o StrictHostKeyChecking=accept-new -i "${SSH_KEY}.pub" "nixos@${STATIC_IP}" >/dev/null
}

partition_and_format() {
  log "partitioning + formatting ${VM_NAME} disk (GPT: ESP=boot, root=nixos)"
  ssh_vm '
    set -e
    while read -r name type; do [ "$type" = disk ] && DISK="/dev/$name" && break; done < <(lsblk -dno NAME,TYPE)
    sudo parted -s "$DISK" -- mklabel gpt
    sudo parted -s "$DISK" -- mkpart ESP fat32 1MiB 513MiB
    sudo parted -s "$DISK" -- set 1 esp on
    sudo parted -s "$DISK" -- mkpart root ext4 513MiB 100%
    sudo partprobe "$DISK"
    sleep 1
    sudo mkfs.fat -F 32 -n boot "${DISK}1"
    sudo mkfs.ext4 -L nixos -F "${DISK}2"
    # first mount can race udev right after mkfs; retry once
    sudo mount -t ext4 "${DISK}2" /mnt || (sleep 2 && sudo mount -t ext4 "${DISK}2" /mnt)
    sudo mkdir -p /mnt/boot
    sudo mount -t vfat "${DISK}1" /mnt/boot
  '
}

provision_repo_and_keys() {
  log "cloning nixbase + copying SSH key onto guest (needed for install-time git push)"
  ssh_vm "GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=accept-new' git clone $REPO_URL ~/nixbase"
  ssh_vm 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'
  scp -o StrictHostKeyChecking=accept-new "$SSH_KEY" "${SSH_KEY}.pub" "${SSH_ALIAS}:~/.ssh/"
  ssh_vm 'chmod 600 ~/.ssh/id_ed25519; chmod 644 ~/.ssh/id_ed25519.pub'
  # inbound access for the installed system's authorized_keys, straight from GitHub
  ssh_vm "mkdir -p ~/nixbase/hosts/${FLAKE_TARGET} && curl -fsSL https://github.com/${GITHUB_USER}.keys > ~/nixbase/hosts/${FLAKE_TARGET}/authorized_keys"
}

run_install() {
  log "running nixos-install --flake .#${FLAKE_TARGET} (this takes a while)"
  ssh_vm "cd ~/nixbase && sudo nixos-install --flake .#${FLAKE_TARGET} --no-root-password --show-trace"
}

boot_installed_system() {
  log "booting the installed system"
  ssh_vm 'sudo umount /mnt/boot /mnt 2>/dev/null; sudo shutdown -h now' || true
  sleep 5
  # Explicitly eject the install media rather than relying on libvirt's
  # undocumented auto-eject-after-install behaviour: with no media in the
  # drive, firmware skips it and falls through to the disk regardless of
  # boot order.
  virsh -c qemu:///system change-media "$VM_NAME" hdb --eject --config >/dev/null 2>&1 || true
  virsh -c qemu:///system start "$VM_NAME"
}

main() {
  command -v virt-install >/dev/null || { echo "virt-install not found"; exit 1; }
  command -v sshpass >/dev/null || sudo apt install -y sshpass
  [ -f "$ISO_PATH" ] || { echo "ISO not found at $ISO_PATH (set ISO_PATH=...)"; exit 1; }

  ensure_default_network
  ensure_iso_accessible
  setup_ssh_config
  recreate_vm
  wait_for_live_shell
  bring_up_live_network
  set_live_password_and_key
  partition_and_format
  provision_repo_and_keys
  run_install
  boot_installed_system

  log "done. VM '$VM_NAME' is booting the installed system."
  log "ssh via: ssh ${SSH_ALIAS}  (user sk / dev, password 123, or your key)"
}

main "$@"
