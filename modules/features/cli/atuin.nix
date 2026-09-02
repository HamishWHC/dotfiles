{
  flake.features.atuin.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.atuin ];
      # xdg.configFile."atuin/config".source = ./config;

      programs.zsh.initContent = ''
        eval "$(atuin init zsh)"
      '';
    };
}
