# QEMU/KVM test VM (WSL2 host) — deterministic by-label devices so this
# stays valid across VM reformats, as long as bootstrap-test-vm.sh keeps
# labeling the ESP "boot" and the root partition "nixos".
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" "ahci" "xhci_pci" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules  = [ ];
  boot.kernelModules         = [ ];
  boot.extraModulePackages   = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device  = "/dev/disk/by-label/boot";
    fsType  = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
