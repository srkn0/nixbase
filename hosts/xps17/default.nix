{ pkgs, lib, sk-ssh-keys, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/profiles/common.nix
    ../../modules/system/nvidia.nix
  ];

  networking.hostName = "xps17";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns   = "systemd-resolved";

  # Secure Boot via lanzaboote — makes TPM2 PCR7 below meaningful.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
  };
  environment.systemPackages = [ pkgs.sbctl ];

  # TPM2 auto-unlock for LUKS root+swap (disko.nix)
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [ "tpm2-device=auto" ];

  # bootstrap-only: initial login for first boot, change via `passwd` after.
  # Keys come from the sk-ssh-keys flake input (github.com/srkn0.keys),
  # pinned in flake.lock — refresh explicitly with `nix flake update
  # sk-ssh-keys`, never re-fetched implicitly on a plain rebuild.
  services.openssh.enable = true;
  users.users.sk.openssh.authorizedKeys.keys =
    lib.filter (k: k != "") (lib.splitString "\n" (builtins.readFile sk-ssh-keys));

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

  system.stateVersion = "26.05";
}
