{
  flake.modules.homeManager.zsh =
    {
      config,
      lib,
      pkgs,
      configDir,
      host,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;

        history = {
          path = "${config.xdg.configHome}/zsh/.zsh_history";
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
          [[ -f "${config.xdg.configHome}/zsh/.zshenv_local" ]] && source "${config.xdg.configHome}/zsh/.zshenv_local"
        '';

        shellAliases = {
          ll = "ls -lA";
          la = "ls -A";
          l = "ls";
          cp = "cp -i";
          mv = "mv -i";
          cdgr = "cd \"$(git rev-parse --show-toplevel)\"";
          restart = "exec \"$SHELL\"";
          docker-ka = "docker kill $(docker ps -q)";
          docker-kra = "docker rm -f $(docker ps -aq)";
          kc = "kubectl";
          kcc = "kubectl ctx";
          kcn = "kubectl ns";
          flush-dns = lib.mkIf pkgs.stdenv.isDarwin "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
          drs = lib.mkIf pkgs.stdenv.isDarwin "sudo /nix/var/nix/profiles/default/bin/nix run nix-darwin#darwin-rebuild -- switch --flake '${configDir}/.#${host}'";
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

            [[ -f "${config.xdg.configHome}/zsh/.zshrc_local" ]] && source "${config.xdg.configHome}/zsh/.zshrc_local"

            source ${./p10k.zsh}
          ''
        ];
      };
    };
}
