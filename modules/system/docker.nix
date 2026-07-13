{
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings.exec-opts = [ "native.cgroupdriver=systemd" ];
}
