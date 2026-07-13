{ ... }:

{
  imports = [
    ../../../../modules/home/shell.nix
    ../../../../modules/home/tools.nix
  ];

  home.username    = "dev";
  home.homeDirectory = "/home/dev";

  programs.git = {
    enable   = true;
    userName = "dev";
  };

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [ "paperwm@paperwm.github.com" ];
    };
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
