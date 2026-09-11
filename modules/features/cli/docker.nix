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
                rm "$out/bin/docker"
                rm "$out/bin/docker-buildx"
                rm "$out/bin/docker-compose"
              '';
            }))
          ])
          ++ (lib.optionals stdenv.hostPlatform.isLinux [
            docker
          ])
          ++ [
            docker-client
            docker-buildx
            docker-compose
          ]
        );

      programs.zsh.shellAliases = {
        docker-ka = "docker kill $(docker ps -q)";
        docker-kra = "docker rm -f $(docker ps -aq)";
      };
    };
}
