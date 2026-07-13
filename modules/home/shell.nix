{ ... }:

{
  programs.zsh = {
    enable            = true;
    enableCompletion  = true;
    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable  = true;
      theme   = "";
      plugins = [ "git" "aliases" "kubectl" "fzf" "zoxide" ];
    };

    initExtra = ''
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi
    '';

    shellAliases = {
      l      = "eza -lah --color=always --icons --group-directories-first";
      la     = "eza -al --color=always --icons --group-directories-first";
      ll     = "eza -l --color=always --icons --group-directories-first";
      lt     = "eza -aT --color=always --icons --group-directories-first";
      fzp    = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
      k      = "kubectl";
      kx     = "kubectx";
      kn     = "kubens";
      lg     = "lazygit";
      vi     = "nvim";
      vim    = "nvim";
      update = "sudo nixos-rebuild switch --flake ~/.config/nixbase#main";
    };

    history.size = 50000;
  };

  programs.starship = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      add_newline     = true;
      command_timeout = 1000;
      format = "$directory$git_branch$git_status$kubernetes$golang$nodejs$python$rust$docker_context$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol   = "[❯](bold red)";
        vimcmd_symbol  = "[❮](bold green)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo  = true;
        style             = "bold cyan";
        read_only         = " ";
      };
      git_branch     = { symbol = " "; style = "bold purple"; };
      git_status     = { style  = "bold yellow"; };
      cmd_duration   = { min_time = 2000; format = "took [$duration]($style) "; style = "bold yellow"; };
      kubernetes     = { disabled = false; symbol = "☸ "; format = "[$symbol$context( \\($namespace\\))]($style) "; style = "bold blue"; };
      golang         = { symbol = " "; };
      nodejs         = { symbol = " "; };
      python         = { symbol = " "; };
      rust           = { symbol = " "; };
      docker_context = { symbol = " "; disabled = false; };
    };
  };

  programs.atuin = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      auto_sync     = false;
      update_check  = false;
      search_mode   = "fuzzy";
      filter_mode   = "global";
      style         = "compact";
      inline_height = 20;
      show_preview  = true;
      enter_accept  = true;
    };
  };

  programs.zoxide = { enable = true; enableZshIntegration = true; };

  programs.direnv = {
    enable               = true;
    enableZshIntegration = true;
    nix-direnv.enable    = true;
  };

  programs.fzf = { enable = true; enableZshIntegration = true; };

  programs.bash = {
    enable           = true;
    enableCompletion = true;
    shellAliases     = { k = "kubectl"; };
  };
}
