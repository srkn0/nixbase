{ ... }:

let
  flake = "~/git/nixbase#xps17";
in
{
  imports = [ ../../../../modules/home/profiles/sk-common.nix ];

  # host-spezifische rebuild-Varianten (brauchen den #host-Attr).
  # host-agnostische nix-Aliase (nxroll/nxgc/nxup/...) liegen in shell.nix.
  programs.zsh.shellAliases = {
    update  = "sudo nixos-rebuild switch --flake ${flake}";   # bauen + jetzt aktiv + bootloader
    nxtest  = "sudo nixos-rebuild test  --flake ${flake}";    # aktiv, aber KEIN bootloader-Eintrag
    nxboot  = "sudo nixos-rebuild boot  --flake ${flake}";    # erst beim naechsten boot aktiv
    nxbuild = "nixos-rebuild build --flake ${flake}";         # nur bauen (->./result), nicht aktivieren
    nxdry   = "nixos-rebuild dry-build --flake ${flake}";     # nur zeigen, was gebaut wuerde
  };
}
