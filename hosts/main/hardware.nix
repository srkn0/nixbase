{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules  = [ ];
  boot.kernelModules         = [ "kvm-amd" ];
  boot.extraModulePackages   = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b2891efe-b275-4ae3-8d11-092334ea6867";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device  = "/dev/disk/by-uuid/5844-3EEA";
    fsType  = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform              = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode  = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
