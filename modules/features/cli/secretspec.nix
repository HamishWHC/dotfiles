{
  flake.features.secretspec.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.unstable.secretspec
      ];
    };
}
