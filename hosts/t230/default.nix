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
  networking.networkmanager.dns   = "systemd-resolved";

  users.users.sk = {
    isNormalUser = true;
    description  = "Serkan K";
    extraGroups  = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      thunderbird
      bitwarden-cli
    ];
  };

  users.users.dev = {
    isNormalUser = true;
    description  = "dev";
    extraGroups  = [ "networkmanager" "docker" ];
  };

  system.stateVersion = "24.11";
}
