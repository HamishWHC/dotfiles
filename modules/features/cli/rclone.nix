{
  flake.features.rclone.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.rclone
      ];
    };
}
