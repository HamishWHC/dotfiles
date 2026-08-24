{
  flake.features.kube.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        kubectl
        kubectx
      ];

      home.file.".kube/config".text = ''

      '';
    };
}
