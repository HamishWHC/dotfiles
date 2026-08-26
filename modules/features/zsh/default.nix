{
  flake.features.zsh.homeManager =
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
            [[ -f "${config.xdg.configHome}/zsh/.zshrc_local" ]] && source "${config.xdg.configHome}/zsh/.zshrc_local"

            source ${./p10k.zsh}
          ''
        ];
      };
    };
}
