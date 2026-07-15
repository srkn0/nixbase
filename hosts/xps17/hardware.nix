# disko.nix owns fileSystems/swapDevices/luks.devices for this host — run
# `nixos-generate-config --no-filesystems --root /mnt` and paste only the
# hardware-detected bits below (kernel modules etc.), not any fileSystems.*
# or swapDevices.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules          = [ "dm_snapshot" ];
  boot.kernelModules                 = [ "kvm-intel" ];
  boot.extraModulePackages           = [ ];

  nixpkgs.hostPlatform  = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
