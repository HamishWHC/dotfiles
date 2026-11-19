{ self, ... }:
{
  flake.features.ssh-client.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      agents = config.dotfiles.ssh-client.agents;
      # SSH talks to a single agent directly, so the agent sees the real
      # requesting process. SSH Agent Mux only runs to combine several.
      useMux = builtins.length agents > 1;
    in
    {
      imports = [ self.features.ssh-agent-mux.homeManager ];

      options.dotfiles.ssh-client.agents = lib.mkOption {
        description = "Upstream SSH agent socket paths, in the order keys should be offered. With more than one, SSH Agent Mux combines them.";
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
          "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        ];
      };

      config = {
        dotfiles.ssh-agent-mux = {
          enable = useMux;
          inherit agents;
        };

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
              IdentityAgent = lib.mkIf (agents != [ ]) (
                if useMux then
                  config.dotfiles.ssh-agent-mux.socketPath
                else
                  # Quoted, as the macOS 1Password path contains a space.
                  ''"${builtins.head agents}"''
              );

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
      };
    };
}
