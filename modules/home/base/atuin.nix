{
  flake-file.inputs.atuin.url = "github:atuinsh/atuin";
  
  flake.modules.homeManager.atuin = {pkgs, ...}: {
    home.packages = [ pkgs.atuin ];
    # xdg.configFile."atuin/config".source = ./config;

    programs.zsh.initContent = ''
      eval "$(atuin init zsh)"
    '';
  };
}