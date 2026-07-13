{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # file management
    nnn
    broot

    # search & text processing
    ripgrep
    fd
    bat
    eza
    jq
    yq-go

    # archives
    zip
    xz
    unzip
    p7zip

    # networking
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc
    wget

    # system monitoring
    btop
    iotop
    iftop
    strace
    ltrace
    lsof
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils

    # misc
    fastfetch
    cowsay
    glow
    hugo
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    nix-output-monitor

    # nerd font
    (nerdfonts.override { fonts = [ "Agave" ]; })
  ];

  fonts.fontconfig.enable = true;
}
