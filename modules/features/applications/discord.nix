{
  flake.features.discord = {
    # darwin = {
    #   homebrew.casks = [ "1password" ];
    # };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.unstable.discord
        ];
      };
  };
}
