{ self, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      imports = [
        self.modules.homeManager.xdg
        self.modules.homeManager.zsh
        self.modules.homeManager.git
        self.modules.homeManager.ssh
        self.modules.homeManager.atuin
        self.modules.homeManager.direnv
      ];

      home.file.".hushlogin".text = "";

      home.packages = with pkgs; [
        bat
        fzf
        ripgrep
        kubectl
        kubectx
        cmake
        pkg-config
        custom.sfs
      ];
    };
}
