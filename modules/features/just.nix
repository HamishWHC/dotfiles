{
  flake.features.just.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unstable.just
        unstable.just-lsp
      ];
    };
}
