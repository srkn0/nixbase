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

  programs.git = {
    enable   = true;
    userName = "sk";
    # userEmail: set locally via `git config --global user.email` or chezmoi
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
