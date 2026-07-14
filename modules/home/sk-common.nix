{ ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./terminal.nix
    ./tools.nix
    ./editor.nix
  ];

  home.username    = "sk";
  home.homeDirectory = "/home/sk";

  home.file.".kube/kuberc".source = ../../config/kuberc;

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi"      = 172;
  };

  programs.git = {
    enable = true;
    settings.user.name  = "srkn0";
    settings.user.email = "srkn0@github";
  };

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [ "paperwm@paperwm.github.com" ];
    };
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
