{ ... }:

{
  programs.kitty = {
    enable = true;
    font   = {
      name = "AgaveNerdFont-Regular";
      size = 11;
    };
    settings = {
      scrollback_lines        = 10000;
      enable_audio_bell       = false;
      update_check_interval   = 0;
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      # Gruvbox Dark
      background            #282828
      foreground            #ebdbb2
      cursor                #ebdbb2
      selection_background  #d65d0e
      color0                #282828
      color1                #cc241d
      color2                #98971a
      color3                #d79921
      color4                #458588
      color5                #b16286
      color6                #689d6a
      color7                #a89984
      color8                #928374
      color9                #fb4934
      color10               #b8bb26
      color11               #fabd2f
      color12               #83a598
      color13               #d3869b
      color14               #8ec07c
      color15               #ebdbb2
    '';
  };

  programs.tmux = {
    enable       = true;
    prefix       = "C-a";
    mouse        = true;
    baseIndex    = 1;
    escapeTime   = 10;
    historyLimit = 50000;
    terminal     = "tmux-256color";
    keyMode      = "vi";
    extraConfig  = ''
      set -ga terminal-overrides ",*256col*:Tc"
      set -g renumber-windows on
      set -g focus-events on
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded"
    '';
  };
}
