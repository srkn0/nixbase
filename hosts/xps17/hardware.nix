# disko.nix owns fileSystems/swapDevices/luks.devices for this host — run
# `nixos-generate-config --no-filesystems --root /mnt` and paste only the
# hardware-detected bits below (kernel modules etc.), not any fileSystems.*
# or swapDevices.
{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules          = [ ];
  boot.kernelModules                 = [ ];
  boot.extraModulePackages           = [ ];

  networking.useDHCP    = lib.mkDefault true;
  nixpkgs.hostPlatform  = lib.mkDefault "x86_64-linux";
}
