{
  flake.features.git.homeManager =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.unstable.gh ];

      programs.git = {
        enable = true;

        includes = [
          { path = "./config_local"; }
          {
            condition = "hasconfig:remote.*.url:https://github.com/**";
            contents.user = {
              name = "HamishWHC";
              email = "20359560+HamishWHC@users.noreply.github.com";
            };
          }
          {
            condition = "hasconfig:remote.*.url:git@github.com:*/**";
            contents.user = {
              name = "HamishWHC";
              email = "20359560+HamishWHC@users.noreply.github.com";
            };
          }
        ];

        settings = {
          url."git@bitbucket.org:".insteadOf = "https://bitbucket.org/";
          url."git@github.com:".insteadOf = "https://github.com/";
          # Git uses the longest matching rule, so this keeps Noctalia's public
          # plugin and template fetches on HTTPS instead of prompting for SSH keys.
          url."https://github.com/noctalia-dev/".insteadOf = "https://github.com/noctalia-dev/";
          pull.rebase = false;
          init.defaultBranch = "main";
          core.excludesfile = "${config.xdg.configHome}/git/ignore";
        };
      };

      xdg.configFile."git/ignore".text = ''
        .DS_Store
        Thumbs.db
        node_modules
        _scratch
      '';
    };
}
