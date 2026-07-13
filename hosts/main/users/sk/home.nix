{ ... }:

{
  imports = [
    ../../../../modules/home/packages.nix
    ../../../../modules/home/shell.nix
    ../../../../modules/home/terminal.nix
    ../../../../modules/home/tools.nix
    ../../../../modules/home/editor.nix
  ];

  home.username    = "sk";
  home.homeDirectory = "/home/sk";

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi"      = 172;
  };

  programs.git = {
    enable   = true;
    userName = "Serkan K";
  };

  programs.zsh.shellAliases.update =
    "sudo nixos-rebuild switch --flake ~/.config/nixbase#main";

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [ "paperwm@paperwm.github.com" ];
    };
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
