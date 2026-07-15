{ pkgs, lib, sk-ssh-keys, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/base.nix
    ../../modules/system/gnome.nix
    ../../modules/system/docker.nix
    ../../modules/system/mullvad.nix
  ];

  networking.hostName = "x230";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns   = "systemd-resolved";

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
