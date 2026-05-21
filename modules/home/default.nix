{self, ...}: {
  flake.modules.homeManager.default = {...}: {
    imports = [
      self.modules.homeManager.packages
      self.modules.homeManager.zsh
      self.modules.homeManager.git
      self.modules.homeManager.ssh
      self.modules.homeManager.ghostty
    ];

    programs.home-manager.enable = true;
  };
}
