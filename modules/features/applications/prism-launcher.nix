{
  flake.features.prism-launcher.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.prismlauncher ];
  };
}
