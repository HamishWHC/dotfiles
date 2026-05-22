{
  flake.modules.homeManager.zsh = {
    config,
    lib,
    pkgs,
    ...
  }:
  {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      history = {
        path = "$HOME/.zsh_history";
        size = 100000;
        save = 100000;
        share = false;
      };

      sessionVariables = {
        EDITOR = "nano";
        BAT_PAGER = "less -RF";
        PAGER = "bat";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      };

      envExtra = ''
        [[ -f ~/.zshenv_local ]] && source ~/.zshenv_local
      '';

      shellAliases = {
        ll = "ls -lA";
        la = "ls -A";
        l = "ls";
        cp = "cp -i";
        mv = "mv -i";
        cdgr = "cd \"$(git rev-parse --show-toplevel)\"";
        restart = "exec \"$SHELL\"";
        flush-dns = lib.mkIf lib.isDarwin "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
        docker-ka = "docker kill $(docker ps -q)";
        docker-kra = "docker rm -f $(docker ps -aq)";
        kc = "kubectl";
        kcc = "kubectl ctx";
        kcn = "kubectl ns";
      };

      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
        {
          name = "z";
          src = pkgs.zsh-z;
          file = "share/zsh-z/zsh-z.plugin.zsh";
        }
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

      initContent = lib.mkMerge [
        (lib.mkBefore ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '')
        ''
          path_remove() {
            PATH=$(echo -n "$PATH" | awk -v RS=: -v ORS=: "\$0 != \"$1\"" | sed 's/:$//')
          }

          path_append() {
            path_remove "$1"
            PATH="''${PATH:+"$PATH:"}$1"
          }

          path_prepend() {
            path_remove "$1"
            PATH="$1''${PATH:+":$PATH"}"
          }

          listening() {
            if [ "$#" -eq 0 ]; then
              sudo lsof -i -P | grep . | awk 'NR == 1 || /LISTEN/'
              return 1
            fi
            if [ "$#" -eq 1 ]; then
              sudo lsof -i -P | grep . | awk 'NR == 1 || (/LISTEN/ && /'"$1"'/)'
              return 0
            fi

            echo "Usage: listening [port]"
            return 1
          }

          [[ -f ~/.zshrc_local ]] && source ~/.zshrc_local

          source ${./p10k.zsh}
        ''
      ];
    };
  };
}
