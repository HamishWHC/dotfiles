{
  flake.modules.homeManager.docker =
    { lib, pkgs, ... }:
    {
      home.packages =
        with pkgs;
        (
          (lib.optionals stdenv.hostPlatform.isDarwin [ orbstack ])
          ++ (lib.optionals stdenv.hostPlatform.isLinux [
            docker
            docker-client
          ])
        );
    };
}
