{
  flake.features.lima.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.unstable.lima
      ];
    };
}
