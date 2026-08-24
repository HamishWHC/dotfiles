{
  flake.features.kube.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        kubectl
        kubectx
        kubecm
        pkgs.unstable.k3d
      ];

      programs.zsh.shellAliases = {
        kc = "kubectl";
        kcc = "kubectx";
        kcn = "kubens";
      };
    };
}
