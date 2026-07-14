{
  flake.features.docker.homeManager =
    { lib, pkgs, ... }:
    {
      home.packages =
        with pkgs;
        (
          (lib.optionals stdenv.hostPlatform.isDarwin [
            (orbstack.overrideAttrs (previousAttrs: {
              postInstall = (previousAttrs.postInstall or "") + ''
                rm "$out/bin/kubectl"
              '';
            }))
          ])
          ++ (lib.optionals stdenv.hostPlatform.isLinux [
            docker
            docker-client
          ])
        );
    };
}
