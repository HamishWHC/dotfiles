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
      ];

      home.packages = with pkgs; [
        bat
        fzf
      ];
    };
}
