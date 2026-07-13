{ pkgs, ... }:

{
  home.packages = with pkgs; [ chezmoi mise ];

  home.file.".config/mise/config.toml".source = ../../mise/config.toml;
}
