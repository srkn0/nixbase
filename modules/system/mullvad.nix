{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable  = true;
    package = pkgs.mullvad-vpn; # CLI + GUI, not just pkgs.mullvad (CLI-only)
  };
}
