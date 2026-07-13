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
    themeFile = "Gruvbox Dark";
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
