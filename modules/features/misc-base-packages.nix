{
  flake.features.misc-base-packages.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bat
        fzf
        ripgrep
        cmake
        pkg-config
        custom.sfs
      ];
    };
}
