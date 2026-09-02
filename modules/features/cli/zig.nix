{
  flake.features.zig.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.unstable.zig
      ];
    };
}
