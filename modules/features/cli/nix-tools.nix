{
  flake.features.nix-tools.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nixfmt
        nixd
        nil
      ];
    };
}
