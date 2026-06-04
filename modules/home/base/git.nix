{
  flake.modules.homeManager.git =
    { config, ... }:
    {
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
          pull.rebase = false;
          init.defaultBranch = "main";
        };
      };
    };
}
