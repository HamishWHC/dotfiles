{
  flake.features.ssh-client.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.ssh-client.agents = lib.mkOption {
        description = "Upstream SSH agent socket paths for SSH Agent Mux, in the order keys should be offered.";
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
          "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        ];
      };

      config = {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          includes = [ "~/.ssh/config_local" ];
          settings = {
            # Makes connections to Git servers persist for longer so I don't have to use TouchID so often.
            "gitlab.cse.unsw.EDU.AU git-codecommit.*.amazonaws.com github.com stash.atlassian.com" = {
              ControlPersist = "1h";
            };

            # Bitbucket is a special snowflake and doesn't support multiplexing.
            "bitbucket.org" = {
              ControlMaster = "no";
            };

            "*" = {
              # Use SSH agent mux to combine multiple agents.
              IdentityAgent = "${config.home.homeDirectory}/.ssh/ssh-agent-mux.sock";

              # Connection persistence options.
              ControlMaster = "auto";
              ControlPath = "~/.ssh/sockets/%r@%h:%p";
              ServerAliveInterval = 60;
              ControlPersist = "1m";
              UseKeychain = lib.mkIf (pkgs.stdenv.isDarwin) "yes";

              # Ghostty SSH Compat
              SetEnv = {
                TERM = "xterm-256color";
              };
            };
          };
        };

        home.activation.createSshSocketDirectory =
          let
            socketDirectory = lib.escapeShellArg "${config.home.homeDirectory}/.ssh/sockets";
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run ${pkgs.coreutils}/bin/mkdir -p -m 0700 ${socketDirectory}
            run ${pkgs.coreutils}/bin/chmod 0700 ${socketDirectory}
          '';

        home.packages = [ pkgs.ssh-agent-mux ];

        xdg.configFile."ssh-agent-mux/ssh-agent-mux.toml".source =
          (pkgs.formats.toml { }).generate "ssh-agent-mux.toml"
            {
              agent_sock_paths = config.dotfiles.ssh-client.agents;
            };

        home.activation.installSshAgentMuxService =
          lib.hm.dag.entryAfter
            [
              "linkGeneration"
              "createSshSocketDirectory"
            ]
            ''
              # The installer invokes launchctl by name, but Home Manager's
              # activation PATH excludes macOS system commands.
              run ${pkgs.coreutils}/bin/env PATH="${lib.optionalString pkgs.stdenv.isDarwin "/bin:"}$PATH" \
                ${lib.getExe pkgs.ssh-agent-mux} --install-service
              ${
                if pkgs.stdenv.isDarwin then
                  ''
                    # Version 0.2.0 installs a disabled launch agent; its restart command
                    # also uses an invalid launchctl status target. Enable/load directly.
                    if ! /bin/launchctl print "gui/$(id -u)/net.ross-williams.ssh-agent-mux" >/dev/null 2>&1; then
                      run /bin/launchctl load -w ${lib.escapeShellArg "${config.home.homeDirectory}/Library/LaunchAgents/net.ross-williams.ssh-agent-mux.plist"}
                    fi
                  ''
                else
                  ''
                    run ${lib.getExe pkgs.ssh-agent-mux} --restart-service
                  ''
              }
            '';
      };
    };
}
