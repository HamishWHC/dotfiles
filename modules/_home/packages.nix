{ pkgs, self, ... }:
{
  home.packages = [
    pkgs.fzf
    pkgs.git
    pkgs.kubectl
    pkgs.kubectx
    pkgs.xh
    self.packages.${pkgs.stdenv.hostPlatform.system}.cat
    self.packages.${pkgs.stdenv.hostPlatform.system}.grep
    self.packages.${pkgs.stdenv.hostPlatform.system}.ls
    self.packages.${pkgs.stdenv.hostPlatform.system}.sfs
    self.packages.${pkgs.stdenv.hostPlatform.system}.usfs
  ];
}
