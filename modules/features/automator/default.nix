{
  flake.features.automator = {
    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf (pkgs.stdenv.isDarwin) {
        home.file."Library/Services/Open in Visual Studio Code.workflow".source =
          ./${"Open in Visual Studio Code.workflow"};
        home.file."Library/Services/Open Terminal Here.workflow".source =
          ./${"Open Terminal Here.workflow"};
      };
  };
}
