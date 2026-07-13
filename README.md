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
    hardware.nix
    users/
      sk/home.nix
      dev/home.nix

modules/
  system/
    base.nix              bootloader, locale, systemd, zsh default shell
    gnome.nix             GNOME + GDM + PaperWM + audio + printing
    nvidia.nix            Nvidia open kernel driver
    docker.nix            Docker (systemd cgroup driver)
  home/
    packages.nix          CLI tools + Agave Nerd Font
    shell.nix             zsh, starship, atuin, zoxide, direnv, fzf
    terminal.nix          kitty, tmux
    tools.nix             mise + mise config
    editor.nix            nvim config (LazyVim) via xdg.configFile

config/
  nvim/                   LazyVim config (deployed by editor.nix)

mise/
  config.toml             dev runtimes: go, node, python, kubectl, k9s, helm…
```

## Stack

| Layer | Tool | Manages |
|-------|------|---------|
| System | NixOS 24.11 + flakes | OS, desktop, drivers, Docker |
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

## Adding a New Host

1. `nixos-generate-config` on the target machine
2. Add `hosts/<name>/hardware.nix` (generated output)
3. Add `hosts/<name>/default.nix` importing the relevant system modules
4. Add `hosts/<name>/users/sk/home.nix` and `users/dev/home.nix`
5. Register in `flake.nix` under `nixosConfigurations`
