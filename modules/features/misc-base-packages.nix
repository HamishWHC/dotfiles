{
  flake.features.misc-base-packages.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unstable.just
        unstable.just-lsp
        bat
        fzf
        ripgrep
        cmake
        pkg-config
        custom.sfs
      ];
    };
}
