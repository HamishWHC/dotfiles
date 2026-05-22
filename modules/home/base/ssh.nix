{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      
      includes = [
        "dns_host_config"
        "dev_env_config"
        "~/.orbstack/ssh/config"
        "~/.ssh/config_local"
      ];

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
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h:%p";
          ServerAliveInterval = 60;
          ControlPersist = "1m";
          UseKeychain = "yes";
        };
      };
    };
  };
}
