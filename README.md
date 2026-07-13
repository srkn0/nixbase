# nixbase

Personal NixOS configuration — flakes, home-manager, mise, chezmoi.

## Structure

```
hosts/
  main/             personal desktop (GNOME + PaperWM, Nvidia)
    default.nix     system config
    hardware.nix    hardware scan — do not edit manually
    home.nix        home-manager: imports modules + desktop extras
  t230/             work machine (home-manager standalone)
    home.nix        home-manager: imports modules

modules/
  system/           reusable NixOS system modules
    base.nix        locale, timezone, bootloader, zsh default shell
    gnome.nix       GNOME + GDM + PaperWM + audio + printing
    nvidia.nix      Nvidia open kernel driver
    docker.nix      Docker engine
  home/             reusable home-manager modules
    packages.nix    base CLI packages + Agave Nerd Font
    shell.nix       zsh, starship, atuin, zoxide, direnv, fzf
    terminal.nix    kitty, tmux
    tools.nix       mise, chezmoi, mise config

mise/
  config.toml       dev runtimes + CLI tools (go, node, kubectl, k9s…)
```

## Stack

| Layer | Tool | Manages |
|-------|------|---------|
| System | NixOS 24.11 + flakes | OS, desktop, drivers, Docker |
| User env | home-manager | shell, terminal, packages, configs |
| Dev tools | [mise](https://mise.jdx.dev) | go, node, python, kubectl, lazygit… |
| Dotfiles | [chezmoi](https://chezmoi.io) | nvim, custom configs, git email |

## First Boot

```bash
# clone repo to a permanent location
git clone git@github.com:srkn0/nixbase.git ~/.config/nixbase
cd ~/.config/nixbase

# main machine
sudo nixos-rebuild switch --flake .#main

# t230 (home-manager standalone)
home-manager switch --flake .#serkan@t230

# install dev tools
mise install

# bootstrap dotfiles (set your git email, nvim config, etc.)
chezmoi init --apply https://github.com/<you>/dotfiles
```

## Day-to-Day

```bash
update                       # rebuild system (alias in shell.nix)
mise use --global node@lts   # add or upgrade a dev tool, then commit mise/config.toml
chezmoi update               # sync dotfiles
```

## Adding a New Host

1. Run `nixos-generate-config` on the target machine
2. Add `hosts/<name>/hardware.nix` (generated output)
3. Add `hosts/<name>/default.nix` importing the relevant system modules
4. Add `hosts/<name>/home.nix` importing the relevant home modules
5. Register in `flake.nix` under `nixosConfigurations`
