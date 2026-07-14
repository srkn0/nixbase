# nixbase

Personal NixOS configuration — two hosts, two users, fully declarative.

## Structure

```
hosts/
  main/                   personal desktop (AMD + Nvidia, GNOME + PaperWM)
    default.nix           system config + user packages
    hardware.nix          generated hardware scan
    users/
      sk/home.nix         full user: shell, terminal, editor, tools
      dev/home.nix        minimal user: shell + tools only
  t230/                   second machine (GNOME + PaperWM, no Nvidia)
    default.nix
    hardware.nix           TODO placeholder until installed on real hardware
    users/
      sk/home.nix
      dev/home.nix
  vm-test/                throwaway QEMU/KVM test VM — mirrors t230, see below
    default.nix
    hardware.nix           deterministic by-label devices (survives reformat)
    authorized_keys

modules/
  system/
    base.nix              bootloader, locale, systemd, zsh default shell
    gnome.nix             GNOME + GDM + PaperWM + audio + printing
    nvidia.nix            Nvidia open kernel driver
    docker.nix            Docker (systemd cgroup driver)
    mullvad.nix            Mullvad VPN (CLI + GUI)
  home/
    packages.nix          CLI tools + apps (browsers, Obsidian, Discord, Spotify) + Agave Nerd Font
    shell.nix             zsh, starship, atuin, zoxide, direnv, fzf
    terminal.nix           kitty, tmux
    tools.nix              mise + mise config
    editor.nix             nvim config (LazyVim) via xdg.configFile

config/
  nvim/                   LazyVim config (deployed by editor.nix)

mise/
  config.toml             dev runtimes: go, node, python, kubectl, k9s, helm…

scripts/
  setup-kvm-wsl.sh        one-time QEMU/KVM/libvirt setup for Ubuntu-on-WSL2
  bootstrap-test-vm.sh    tears down + recreates the vm-test VM end to end
```

## Stack

| Layer | Tool | Manages |
|-------|------|---------|
| System | NixOS 26.05 + flakes | OS, desktop, drivers, Docker |
| User env | home-manager | shell, terminal, editor, packages |
| Dev tools | [mise](https://mise.jdx.dev) | go, node, python, kubectl, lazygit… |

## First Boot

```bash
git clone git@github.com:srkn0/nixbase.git ~/.config/nixbase
cd ~/.config/nixbase

# apply system + home config
sudo nixos-rebuild switch --flake .#main   # or .#t230

# install dev runtimes
mise install
```

## Day-to-Day

```bash
update                       # rebuild (alias in each host's sk/home.nix)
mise use --global node@lts   # add/upgrade a dev tool, commit mise/config.toml
```

## Setting Up t230 (Real Hardware)

`hosts/t230/hardware.nix` is still a TODO placeholder — it's never been run on
the actual laptop. Path to a real install:

1. Boot a NixOS installer ISO on the t230.
2. Partition + format the disk, mount at `/mnt` (`/` + `/boot` at minimum).
3. `nixos-generate-config --root /mnt` — replace `hosts/t230/hardware.nix`'s
   `device = "TODO"` lines with the generated file's real UUIDs/modules.
4. `git clone git@github.com:srkn0/nixbase.git`, then from inside it:
   `sudo nixos-install --flake .#t230`
5. `sk`/`dev` start with `initialPassword = "123"` and SSH access is
   preloaded from `github.com/srkn0.keys` (pinned in `flake.lock` as the
   `sk-ssh-keys` input — refresh with `nix flake update sk-ssh-keys`, never
   fetched implicitly). **Change the bootstrap password on first login**:
   `passwd`.

No `--impure` needed anywhere — the SSH-key fetch is a locked flake input,
not a live network call during evaluation.

## Testing Changes in a VM

Before touching real hardware, validate a config end-to-end in a throwaway
QEMU/KVM VM (`hosts/vm-test`, mirrors t230's modules/users against
deterministic VM hardware):

```bash
task setup-kvm       # one-time: QEMU/KVM/libvirt/virt-manager on Ubuntu-WSL2
task vm:bootstrap     # tear down + recreate the VM, install vm-test end-to-end
task vm:ssh           # ssh in as sk (password 123, or your key)
task vm:destroy       # stop + remove it
```

`vm:bootstrap` always starts clean (destroys any existing VM + disk) — it's
meant to prove a config installs and boots correctly from scratch, not to be
incremental. See `scripts/bootstrap-test-vm.sh` for what it automates
(UEFI firmware, live-ISO network bring-up, partitioning, install) and why
(WSL2 Mirrored networking breaks libvirt's default DHCP — see the script's
`ensure_default_network`).

## Adding a New Host

1. `nixos-generate-config` on the target machine
2. Add `hosts/<name>/hardware.nix` (generated output)
3. Add `hosts/<name>/default.nix` importing the relevant system modules
4. Add `hosts/<name>/users/sk/home.nix` and `users/dev/home.nix`
5. Register in `flake.nix` under `nixosConfigurations`
