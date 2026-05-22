{
  flake.modules.homeManager.runtimes = {config, pkgs, ...}: {
    home.packages = [
      pkgs.nodejs_25
      pkgs.rustc
      pkgs.rust-analyzer
    ];

    programs.uv.enable = true;
    programs.cargo.enable = true;
    programs.bun.enable = true;
    programs.go.enable = true;
    programs.go.env.GOPATH = "${config.xdg.dataDir}/go";
  };
}