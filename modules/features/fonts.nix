{
  flake.features.fonts = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.nerd-fonts.fira-code
        ];
      };
  };
}
