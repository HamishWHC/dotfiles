{
  flake.features.ghidra.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ghidra ];
    };
}
