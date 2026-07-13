{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/base.nix
    ../../modules/system/gnome.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/docker.nix
  ];

  networking.hostName = "main";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns   = "systemd-resolved";
  networking.extraHosts = ''
    192.168.178.50 gitlab.srkn.me
  '';

  users.users.sk = {
    isNormalUser = true;
    description  = "srkn0";
    extraGroups  = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      thunderbird
      chromium
      bitwarden-desktop
      bitwarden-cli
      lens
      opentabletdriver
      xournalpp
      nfs-utils
      tilt
    ];
  };

  users.users.dev = {
    isNormalUser = true;
    description  = "dev";
    extraGroups  = [ "networkmanager" "docker" ];
  };

  system.stateVersion = "24.11";
}
