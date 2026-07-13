{ pkgs, ... }:

{
  imports = [
    ../../modules/home/packages.nix
    ../../modules/home/shell.nix
    ../../modules/home/terminal.nix
    ../../modules/home/tools.nix
  ];

  home.username    = "serkan";
  home.homeDirectory = "/home/serkan";

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi"      = 172;
  };

  programs.git = {
    enable   = true;
    userName = "sk";
    # userEmail: set locally via `git config --global user.email` or chezmoi
  };

  # Desktop-only packages
  home.packages = with pkgs; [
    opentabletdriver
    xournalpp
    nfs-utils
    tilt
  ];

  # Enable PaperWM via dconf
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [ "paperwm@paperwm.github.com" ];
    };
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
