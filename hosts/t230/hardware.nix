# Run `nixos-generate-config` on the t230 and replace this file with the output.
{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules          = [ ];
  boot.kernelModules                 = [ ];
  boot.extraModulePackages           = [ ];

  fileSystems."/" = {
    device = "TODO";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device  = "TODO";
    fsType  = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  networking.useDHCP    = lib.mkDefault true;
  nixpkgs.hostPlatform  = lib.mkDefault "x86_64-linux";
}
