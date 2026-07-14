{ inputs, ... }:
{
  flake-file.inputs = {
    direnv-instant.url = "github:Mic92/direnv-instant";
  };

  flake.modules.homeManager.direnv = {
    imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

    programs.direnv-instant.enable = true;
  };
}
