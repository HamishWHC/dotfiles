{
  flake.features.kube.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.kube.k3d.package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.unstable.k3d;
        description = "k3d package to install.";
      };

      config = {
        home.packages = with pkgs; [
          kubectl
          kubectx
          kubecm
          kubernetes-helm
          kapp
          kbld
          yq
          config.dotfiles.kube.k3d.package
        ];

        programs.zsh.shellAliases = {
          kc = "kubectl";
          kcc = "kubectx";
          kcn = "kubens";
        };
      };
    };
}
