{ ... }:
{
  programs.git = {
    enable = true;

    settings = {
      url = {
        "git@bitbucket.org:".insteadOf = "https://bitbucket.org/";
        "git@github.com:".insteadOf = "https://github.com/";
      };

      pull.rebase = false;
      init.defaultBranch = "main";

      include.path = "~/.gitlocalconfig";

      includeIf = {
        "hasconfig:remote.*.url:https://github.com/**".path = "${../../configs/git/github}";
        "hasconfig:remote.*.url:git@github.com:*/**".path = "${../../configs/git/github}";
      };
    };
  };
}
