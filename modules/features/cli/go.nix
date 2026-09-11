{
  flake.features.go.homeManager =
    { config, ... }:
    {
      programs.go.enable = true;
      programs.go.env.GOPATH = "${config.xdg.dataHome}/go";
    };
}
