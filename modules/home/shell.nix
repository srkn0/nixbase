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
      plugins = [ "git" "aliases" "fzf" "zoxide" ];
    };

    # kubectl-Familie bleibt hier (kubecolor-Wrapper). Alle anderen Aliase
    # (l/la/ll/lt/fzp/lg/vi/vim + nx*) sind nach cx migriert und kommen jetzt
    # aus config/cx/aliases.sh — pflegen/anlegen via `cx` (^a). Die
    # host-spezifischen rebuild-Aliase (update/nxtest/...) liegen pro Host.
    shellAliases = {
      kubectl = "kubecolor";
      k       = "kubecolor";
      kx      = "kubectx";
      kn      = "kubens";
    };

    initContent = ''
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi

      # ad-hoc Paket aus nixpkgs starten / in Shell holen
      nxrun()   { nix run   "nixpkgs#''${1}" "''${@:2}" }   # nxrun cowsay moo
      nxshell() { nix shell "nixpkgs#''${1}" }               # nxshell ripgrep

      # exec shell into pod: ksh <pod> [container]
      ksh() { kubectl exec -it "''${1}" ''${2:+"-c" "''${2}"} -- /bin/sh }
      kbash() { kubectl exec -it "''${1}" ''${2:+"-c" "''${2}"} -- /bin/bash }

      # spawn ephemeral netshoot debug pod (auto-deleted on exit)
      knetshoot() { kubectl run netshoot-tmp --rm -it --image=nicolaka/netshoot --restart=Never -- /bin/bash }

      # port-forward: kpf <resource> <port> [remote-port]
      kpf() { kubectl port-forward "''${1}" "''${2}:''${3:-''${2}}" }

      # find OOMKilled pods across current namespace
      koom() {
        kubectl get pods -o json | jq -r '
          .items[] | . as $pod |
          .status.containerStatuses[]? |
          select(.lastState.terminated.reason == "OOMKilled") |
          [$pod.metadata.name, .name, "OOMKilled"] | join("  ")
        '
      }

      # decode all values of a secret
      ksecret() { kubectl get secret "''${1}" -o json | jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"' }

      # show image running in every container across all pods
      kimgs() { kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' | column -t }

      # live diff: running resource vs local file
      kdiff() { diff <(kubectl get "''${1}" -o yaml | kubectl neat) "''${2}" }

      # get all pods not in Running/Completed state
      kbad() { kubectl get pods --field-selector='status.phase!=Running,status.phase!=Succeeded' }

      # quick rollout restart
      krollout() { kubectl rollout restart "''${1}" }
    '';

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
