#!/usr/bin/env bash
# QEMU/KVM + libvirt + virt-manager setup for Ubuntu-on-WSL2.
# Prereqs already confirmed working: /dev/kvm present (nested virt works),
# systemd is PID 1, WSLg active (DISPLAY/WAYLAND_DISPLAY set) -> no custom
# kernel, no wsl.conf systemd hack, no external X server (e.g. X410) needed.
set -euo pipefail

echo "==> Sanity checks"
if [ ! -e /dev/kvm ]; then
  echo "ERROR: /dev/kvm not found. Check nestedVirtualization=true in .wslconfig on Windows and 'wsl --shutdown' + restart." >&2
  exit 1
fi
if [ "$(ps -p 1 -o comm=)" != "systemd" ]; then
  echo "ERROR: systemd is not PID 1. Enable systemd in /etc/wsl.conf ([boot] systemd=true), then 'wsl --shutdown' + restart." >&2
  exit 1
fi

echo "==> Installing packages"
sudo apt update
sudo apt install -y \
  qemu-system-x86 \
  qemu-utils \
  libvirt-daemon-system \
  libvirt-clients \
  virtinst \
  virt-manager \
  ovmf \
  sshpass

echo "==> Adding $USER to kvm and libvirt groups"
sudo usermod -aG kvm,libvirt "$USER"

echo "==> Enabling libvirtd"
sudo systemctl enable --now libvirtd

echo "==> Setting up default NAT network"
# WSL2 Mirrored networking mode (networkingMode=Mirrored in .wslconfig) syncs
# Windows' excluded port ranges into the guest netns, so dnsmasq can never
# bind :67 (DHCP) on this network. Fix: disable dhcp+dns so libvirt never
# spawns dnsmasq for it, just plain NAT+bridge. If you're on NAT networking
# mode instead of Mirrored, DHCP would work fine, but this is safe either way.
if sudo virsh net-dumpxml default 2>/dev/null | grep -q "<dhcp>"; then
  echo "    disabling DHCP/DNS on 'default' network (WSL2 mirrored-mode workaround)"
  sudo virsh net-destroy default 2>/dev/null || true
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
  sudo virsh net-define "$netxml"
  rm -f "$netxml"
fi
sudo virsh net-autostart default
sudo virsh net-info default | grep -q "^Active:\s*yes" || sudo virsh net-start default

echo
echo "==> Done. Current state:"
sudo virsh net-list --all
echo
echo "NOTE: Group membership (kvm, libvirt) only takes effect in a NEW session."
echo "Log out/in of this WSL shell (or run 'wsl --shutdown' from Windows and reopen),"
echo "then verify with: groups"
echo "and launch the GUI with: virt-manager"
