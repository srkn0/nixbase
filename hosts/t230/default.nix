{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/base.nix
    ../../modules/system/gnome.nix
    ../../modules/system/docker.nix
  ];

  networking.hostName = "t230";
  networking.networkmanager.enable = true;

  users.users.sk = {
    isNormalUser = true;
    description  = "srkn0";
    extraGroups  = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      thunderbird
      bitwarden-desktop
      bitwarden-cli
      code-cursor
      vscode
    ];
  };

  users.users.dev = {
    isNormalUser = true;
    description  = "dev";
    extraGroups  = [ "networkmanager" "docker" ];
    packages = with pkgs; [
      code-cursor
      vscode
    ];
  };

  system.stateVersion = "24.11";
}
