# Throwaway QEMU/KVM VM target — mirrors t230's system module list and
# user accounts so we're testing the same surface, just against VM
# hardware. Home-manager config (flake.nix) reuses t230's actual
# home.nix files directly rather than duplicating them.
{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/base.nix
    ../../modules/system/gnome.nix
    ../../modules/system/docker.nix
  ];

  networking.hostName = "vm-test";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns   = "systemd-resolved";

  # test-only convenience: remote access for iterating from the host
  services.openssh.enable = true;
  users.users.sk.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];

  users.users.sk = {
    isNormalUser = true;
    description  = "srkn0";
    extraGroups  = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "123";
    packages = with pkgs; [
      thunderbird
      bitwarden-cli
    ];
  };

  users.users.dev = {
    isNormalUser = true;
    description  = "dev";
    extraGroups  = [ "networkmanager" "docker" ];
    initialPassword = "123";
  };

  system.stateVersion = "24.11";
}
