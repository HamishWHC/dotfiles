{
  flake.features.misc-base-packages.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unstable.just
        unstable.just-lsp
        gum
        jq
        bat
        fzf
        ripgrep
        cloc
        cmake
        pkg-config
        custom.sfs
      ];
    };
}
