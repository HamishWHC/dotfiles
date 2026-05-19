{ ... }:
{
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
      "gitlab.cse.unsw.EDU.AU git-codecommit.*.amazonaws.com github.com stash.atlassian.com" = {
        ControlPersist = "1h";
      };

      "bitbucket.org" = {
        ControlMaster = "no";
      };

      "*" = {
        AddKeysToAgent = "no";
        Compression = "no";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h:%p";
        ControlPersist = "1m";
        ForwardAgent = "no";
        HashKnownHosts = "no";
        ServerAliveInterval = 60;
        UseKeychain = "yes";
      };
    };
  };
}
