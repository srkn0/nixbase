# nixbase

Personal NixOS configuration — two laptops, one user (`sk`), fully declarative.

## Structure

```
hosts/
  x230/                   ThinkPad X230 (GNOME + PaperWM, Intel, LUKS via disko)
    default.nix
    hardware.nix
    disko.nix             declarative disk layout
    users/sk/home.nix
  xps17/                  Dell XPS 17 (GNOME + PaperWM, Nvidia, Secure Boot via lanzaboote)
    default.nix
    hardware.nix
    disko.nix
    users/sk/home.nix

modules/
  system/
    base.nix              bootloader, locale, zsh default shell, sudo timestamp sharing
    gnome.nix             GNOME + GDM + PaperWM + audio + printing
    nvidia.nix            Nvidia open kernel driver
    docker.nix            Docker (systemd cgroup driver)
    mullvad.nix           Mullvad VPN (CLI + GUI)
    profiles/
      common.nix          shared system bundle (base + gnome + docker + mullvad)
  home/
    packages.nix          CLI tools + apps (Chrome, Obsidian, Discord, Spotify, Zed) + Agave Nerd Font
    shell.nix             zsh, starship, atuin, zoxide, direnv, fzf
    terminal.nix          kitty, tmux
    tools.nix             mise + config, best-effort `mise install` on rebuild
    editor.nix            nvim config (LazyVim) via xdg.configFile
    commands.nix          cx command library + shortcut aliases
    profiles/
      sk-common.nix       full "sk" home bundle (imports the leaf modules above)

config/
  nvim/                   LazyVim config (deployed by editor.nix)
  cx/                     cx command packs + generated aliases

mise/
  config.toml             dev runtimes: go, node, python, kubectl, k9s, helm…

pkgs/
  cx/                     cx TUI (Go) — browsable command library / shortcut manager
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
sudo nixos-rebuild switch --flake .#x230   # or .#xps17

# install dev runtimes
mise install
```

## Day-to-Day

```bash
update                       # rebuild (alias in each host's sk/home.nix)
mise use --global node@lts   # add/upgrade a dev tool, commit mise/config.toml
cx                           # browse the command library / manage shortcuts
```

> **Note:** mise runtimes live outside Nix. `modules/home/tools.nix` runs a
> best-effort `mise install` on every rebuild via a home-manager activation
> hook — network-guarded and `|| true`, so it never fails a switch when offline.
> Run `mise install` manually after a fresh bootstrap if you were offline during
> the first rebuild.

### `cx` — command library & shortcuts

`cx` (source in `pkgs/cx`, packaged by `modules/home/commands.nix`) browses YAML
command "packs" in `config/cx/*.yaml` and manages shortcuts:

- browse categories (→/←) or type to fuzzy-search over name + description + command
- `⏎` puts the selected command on your prompt (editable)
- **full CRUD in arrow-navigable modal dialogs**: `^n` new command, `^g` new
  category (sub-category, or a new top-level pack file), `^e` edit, `^x` delete
  (confirm), `^a` set/edit a command's alias (live conflict check)
- a command's alias is an inline `alias:` field in its pack. cx owns the pack
  files and writes them directly — no separate overlay, what you see is the file.
- aliases compile to `config/cx/aliases.sh`, sourced by zsh **and** bash — a new
  shell has the alias immediately, no rebuild. `cx --gen-aliases` regenerates it.
- `$CX_DIR` points at this repo, so pack/alias edits are live without a rebuild.
- theming via `$CX_THEME` (`mocha` · `tokyonight` · `latte`), animated gradient
  logo; add icons with `icon: ""` on any pack entry (Nerd Font glyphs).

## Setting Up x230 (Real Hardware)

`hosts/x230/hardware.nix` is still a TODO placeholder — it's never been run on
the actual laptop. Path to a real install:

1. Boot a NixOS installer ISO on the x230.
2. Partition + format the disk, mount at `/mnt` (`/` + `/boot` at minimum).
3. `nixos-generate-config --root /mnt` — replace `hosts/x230/hardware.nix`'s
   `device = "TODO"` lines with the generated file's real UUIDs/modules.
4. `git clone git@github.com:srkn0/nixbase.git`, then from inside it:
   `sudo nixos-install --flake .#x230`
5. `sk`/`dev` start with `initialPassword = "123"` and SSH access is
   preloaded from `github.com/srkn0.keys` (pinned in `flake.lock` as the
   `sk-ssh-keys` input — refresh with `nix flake update sk-ssh-keys`, never
   fetched implicitly). **Change the bootstrap password on first login**:
   `passwd`.

No `--impure` needed anywhere — the SSH-key fetch is a locked flake input,
not a live network call during evaluation.

## Testing Changes in a VM

This repo used to carry a `vm-test` host plus WSL2/QEMU automation to validate a
config end-to-end in a throwaway VM before touching real hardware. Now that the
laptops run the config directly, that scaffolding was removed — the full
approach (WSL2 KVM setup, the libvirt mirrored-networking DHCP gotcha,
blind-keystroke live-ISO automation, partition + `nixos-install`) is written up
on my blog: **[Testing a NixOS flake config end-to-end in a throwaway WSL2/KVM
VM](/blog/nixos-flake-vm-test-on-wsl2)**.

## Adding a New Host

1. `nixos-generate-config` on the target machine
2. Add `hosts/<name>/hardware.nix` (generated output)
3. Add `hosts/<name>/default.nix` importing the relevant system modules
4. Add `hosts/<name>/users/sk/home.nix` and `users/dev/home.nix`
5. Register in `flake.nix` under `nixosConfigurations`
