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
  networking.extraHosts = ''
    192.168.178.50 gitlab.srkn.me
  '';

  users.users.serkan = {
    isNormalUser = true;
    description  = "serkan";
    extraGroups  = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      thunderbird
      chromium
      bitwarden-desktop
      bitwarden-cli
      lens
      code-cursor
      vscode
      spotify
      openvpn
      nextcloud-client
      gearlever
    ];
  };

  system.stateVersion = "24.11";
}
