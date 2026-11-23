{
  flake.features.zsh = {
    darwin = { lib, pkgs, username, ... }: {
      programs.zsh.enable = true;
      programs.zsh.enableGlobalCompInit = false;
      users.users.${username}.shell = pkgs.zsh;
      # Existing macOS accounts are not in users.knownUsers. Set only their
      # login shell rather than taking ownership of their UID and groups.
      system.activationScripts.postActivation.text = lib.mkAfter ''
        /usr/bin/dscl . -create ${lib.escapeShellArg "/Users/${username}"} UserShell /run/current-system/sw/bin/zsh
      '';
    };
    nixos = { pkgs, username, ... }: {
      programs.zsh.enable = true;
      programs.zsh.enableGlobalCompInit = false;
      users.defaultUserShell = pkgs.zsh;
      users.users.${username}.shell = pkgs.zsh;
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        programs.zoxide.enable = true;

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
            ls = "ls --color=auto -h";
            la = "ls -lA";
            cp = "cp -i";
            mv = "mv -i";
            rm = "rm -I";
            cdgr = "cd \"$(git rev-parse --show-toplevel)\"";
            restart = "exec \"$SHELL\"";
            flush-dns = lib.mkIf pkgs.stdenv.isDarwin "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
          };

          plugins = [
            {
              name = "fzf-tab";
              src = pkgs.zsh-fzf-tab;
              file = "share/fzf-tab/fzf-tab.plugin.zsh";
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
              [[ -f "${config.xdg.configHome}/zsh/.zshrc_local" ]] && source "${config.xdg.configHome}/zsh/.zshrc_local"

              source ${./p10k.zsh}

              # nix-darwin's /etc/zshrc doesn't bind these keys the way
              # Apple's does, so zsh would type the trailing `~` of e.g.
              # Delete. Bind the normal and application-mode forms here.
              bindkey '^[[3~' delete-char           # Delete
              bindkey '^[[3;5~' kill-word           # Ctrl+Delete
              bindkey '^[[3;3~' kill-word           # Alt+Delete
              bindkey '^[[H' beginning-of-line      # Home
              bindkey '^[OH' beginning-of-line
              bindkey '^[[F' end-of-line            # End
              bindkey '^[OF' end-of-line
              bindkey '^[[1;5D' backward-word       # Ctrl+Left
              bindkey '^[[1;5C' forward-word        # Ctrl+Right
              bindkey '^[[1;3D' backward-word       # Alt+Left
              bindkey '^[[1;3C' forward-word        # Alt+Right

              # Flag to track if the terminal is still on its first prompt
              _IS_FIRST_PROMPT=true

              # Set the flag to false after the first prompt is used.
              # Reset to true when the user runs clear.
              autoload -Uz add-zsh-hook
              _reset_first_prompt_flag() {
                _IS_FIRST_PROMPT=false
                if [[ "$1" =~ "^\s*clear\s*$" ]]; then
                  _IS_FIRST_PROMPT=true
                fi
              }
              add-zsh-hook preexec _reset_first_prompt_flag

              # Clear the screen on window resize only if the flag is true.
              function TRAPWINCH() {
                if [[ "$_IS_FIRST_PROMPT" == true ]]; then
                  zle && zle clear-screen && zle reset-prompt 2>/dev/null
                fi
              }
            ''
          ];
        };
      };
  };
}
