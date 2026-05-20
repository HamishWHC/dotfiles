{ ... }:
{
  flake.homeModules.zsh = { config, lib, pkgs, ... }: {
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      envExtra = ''
        export EDITOR=nano
        export BAT_PAGER="less -RF"
        export PAGER="bat"
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"

        [[ -f ~/.zshenv_local ]] && source ~/.zshenv_local
      '';

      shellAliases = {
        ll = "ls -lA";
        la = "ls -A";
        l = "ls";
        cp = "cp -i";
        mv = "mv -i";
        restart = ''exec "$SHELL"'';
        flush-dns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
        cdgr = ''cd "$(git root)"'';
        docker-ka = ''docker kill $(docker ps -q)'';
        docker-kra = ''docker rm -f $(docker ps -aq)'';
        kc = "kubectl";
        kcc = "kubectl ctx";
        kcn = "kubectl ns";
      };

      initContent = lib.mkOrder 1000 ''
        ZSH_AUTOSUGGEST_MANUAL_REBIND=1

        export GOPATH="$HOME/.go"
        zle_highlight+=(paste:none)

        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

        alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

        dfu() {
          (
            cd ~/.dotfiles && git pull --ff-only && darwin-rebuild switch --flake .
          )
        }

        hist() {
          local COMMAND="$(sed -r "s/^: [0-9]+:[0-9]+;//g" ~/.zsh_history | fzf --tac)"
          if [ "$COMMAND" != "" ]; then
            echo $COMMAND | tr -d '\n' | pbcopy
            echo "Copied:" $COMMAND
          fi
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

        mcd() {
          mkdir "''${1}" && cd "''${1}"
        }

        up() {
          local cdir="$(pwd)"
          if [[ "''${1}" == "" ]]; then
            cdir="$(dirname "''${cdir}")"
          elif ! [[ "''${1}" =~ ^[0-9]+$ ]]; then
            echo "Error: argument must be a number"
          elif ! [[ "''${1}" -gt "0" ]]; then
            echo "Error: argument must be positive"
          else
            for ((i = 0; i < ''${1}; i++)); do
              local ncdir="$(dirname "''${cdir}")"
              if [[ "''${cdir}" == "''${ncdir}" ]]; then
                break
              else
                cdir="''${ncdir}"
              fi
            done
          fi
          cd "''${cdir}"
        }

        ntfy() {
          local topic=$1
          https ntfy.hamishwhc.com/$topic/publish -A basic -a $NTFY_USER:$NTFY_PASS ''${@:2}
        }

        notes() {
          local title=$@
          local dir="$HOME/Desktop/quick-notes/$(date "+%Y-%m-%d")"
          mkdir -p $dir
          if [[ $title != "" ]]; then
            local file="$dir/$title.md"
            echo "# $title" >$file
          else
            local file="$dir/$(date "+%H.%M").md"
          fi
          code -n $file
        }

        scratch() {
          local title=$1
          local dir="$HOME/Desktop/scratch/$(date "+%Y-%m-%d")"
          if [[ $title != "" ]]; then
            dir="$dir-$title"
          fi
          mkdir -p $dir
          code $dir
        }

        [[ -f ~/.zshrc_local ]] && source ~/.zshrc_local
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';
    };

    home.file.".p10k.zsh".source = ../../home/.p10k.zsh;
  };
}
