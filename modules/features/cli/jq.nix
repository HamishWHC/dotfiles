{
  flake.features.jq.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.jq
        pkgs.jqp
      ];
    };
}
