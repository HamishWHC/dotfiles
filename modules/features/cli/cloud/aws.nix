{
  flake.features.aws.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.awscli2
        pkgs.awsume
      ];
    };
}
