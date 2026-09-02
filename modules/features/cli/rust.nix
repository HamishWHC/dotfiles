{
  flake.features.rust.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.rustup
      ];
    };
}
