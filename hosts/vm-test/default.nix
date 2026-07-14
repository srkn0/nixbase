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

  # libvirt's "default" network runs with DHCP disabled (WSL2 mirrored-mode
  # breaks dnsmasq's DHCP socket bind), so a static profile is required —
  # plain DHCP-via-NetworkManager would never get an address.
  environment.etc."NetworkManager/system-connections/static-test.nmconnection" = {
    text = ''
      [connection]
      id=static-test
      type=ethernet
      interface-name=ens3
      autoconnect=true

      [ipv4]
      method=manual
      addresses1=192.168.122.10/24
      gateway=192.168.122.1
      dns=1.1.1.1;

      [ipv6]
      method=ignore
    '';
    mode = "0600";
  };

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
