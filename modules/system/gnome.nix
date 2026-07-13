{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout  = "de";
    variant = "";
  };
  console.keyMap = "de";

  services.printing.enable = true;
  services.flatpak.enable = true;
  programs.firefox.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.paperwm
    gnome-tweaks
  ];
}
