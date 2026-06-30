{
  flake.modules.homeManager.runtimes =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        nodejs
        rustc
        rust-analyzer
        pnpm
      ];

      programs.uv.enable = true;
      programs.cargo.enable = true;
      programs.bun.enable = true;
      programs.go.enable = true;
      programs.go.env.GOPATH = "${config.xdg.dataHome}/go";
    };
}
