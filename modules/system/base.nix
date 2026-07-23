{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = false;
  services.resolved = {
    enable = true;
    settings.Resolve.DNS = "1.1.1.1 9.9.9.9";
    settings.Resolve.FallbackDNS = "8.8.8.8 8.8.4.4";
    settings.Resolve.DNSSEC = "allow-downgrade";
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    gcc
    binutils
    gnumake
    cmake
    pkg-config
  ];

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Share sudo's auth timestamp across sk's sessions — including nvim's non-tty
  # sudo subprocesses (suda / SudoBrowse) — and keep it 30 min. This lets a
  # single authentication unlock root file access in nvim without sudo ever
  # grabbing the terminal (which corrupts the TUI). !tty_tickets = one shared
  # timestamp per user instead of one per tty.
  security.sudo.extraConfig = ''
    Defaults:sk timestamp_timeout=30
    Defaults:sk !tty_tickets
  '';

  # Required for dynamically linked binaries installed via mise (node, python, etc.)
  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfree = true;
}
