{
  flake.features.terraform.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.terraform
        pkgs.opentofu
      ];
    };
}
