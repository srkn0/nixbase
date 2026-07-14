{ ... }:

{
  imports = [ ../../../../modules/home/sk-common.nix ];

  programs.zsh.shellAliases.update =
    "sudo nixos-rebuild switch --flake ~/git/nixbase#x230";
}
