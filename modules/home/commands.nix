{ config, pkgs, ... }:

let
  # cx: browsable command library + shortcut manager (source in pkgs/cx).
  cx = pkgs.buildGoModule {
    pname = "cx";
    version = "0.1.0";
    src = ../../pkgs/cx;
    vendorHash = "sha256-cpZVWNgH/SoTu117Iby4QExgP0ROPzWju6A0iUkyQ1o=";
    meta.description = "Browsable command library + shortcut manager (TUI)";
  };

  # cx reads packs + writes shortcuts here. Pointed straight at the repo so
  # edits and new shortcuts are live immediately — no rebuild needed. Nix only
  # provisions the binary, the $CX_DIR export and the aliases.sh source line.
  cxDir = "${config.home.homeDirectory}/git/nixbase/config/cx";

  cxShellInit = ''
    export CX_DIR="${cxDir}"
    export CX_THEME="''${CX_THEME:-mocha}"   # mocha · tokyonight · latte
    [ -f "$CX_DIR/aliases.sh" ] && . "$CX_DIR/aliases.sh"
  '';
in
{
  home.packages = [ cx ];

  # zsh: the picked command lands editable on the prompt (print -z) + in history.
  # CX_ALIASES hands cx the live alias names so it can warn about clashes.
  programs.zsh.initContent = cxShellInit + ''
    cx() {
      local c
      c="$(CX_ALIASES="''${(k)aliases}" command cx "$@")" || return
      [ -n "$c" ] && { print -s -- "$c"; print -z -- "$c"; }
    }
  '';

  # bash: picked command goes to history (press Up to recall/run it).
  programs.bash.initExtra = cxShellInit + ''
    cx() {
      local c
      c="$(CX_ALIASES="$(compgen -a)" command cx "$@")" || return
      [ -n "$c" ] && { history -s "$c"; printf '%s\n' "$c"; }
    }
  '';
}
