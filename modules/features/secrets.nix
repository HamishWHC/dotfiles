{ inputs, ... }:
{
  flake.features.secrets = {
    darwin =
      {
        username,
        ...
      }:
      {
        imports = [ inputs.sops-nix.darwinModules.sops ];

        sops = {
          defaultSopsFile = ../../secrets/default.yaml;
          age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";

          secrets.github-token = {
            key = "github_token";
            owner = username;
            mode = "0400";
          };
        };
      };

    homeManager =
      { config, lib, pkgs, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];

        sops = {
          defaultSopsFile = ../../secrets/default.yaml;
          age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          age.plugins = lib.optionals pkgs.stdenv.isDarwin [ pkgs.unstable.age-plugin-se ];
        };

        # Upstream's Darwin activation only bootstraps an asynchronous agent.
        # Run its generated decryption script synchronously so later activation
        # entries can consume fresh secrets. Home Manager still installs the
        # login agent afterwards to restore temporary secrets after a reboot.
        home.activation.sops-nix = lib.mkIf (pkgs.stdenv.isDarwin && config.sops.secrets != { }) (
          lib.mkForce (lib.hm.dag.entryBetween [ "setupLaunchAgents" ] [ "writeBoundary" ] ''
            run ${pkgs.coreutils}/bin/env \
              ${lib.escapeShellArgs (lib.mapAttrsToList (name: value: "${name}=${toString value}") config.sops.environment)} \
              ${config.launchd.agents.sops-nix.config.Program}
          '')
        );

        home.packages = with pkgs; [
          sops
          age
        ] ++ lib.optionals pkgs.stdenv.isDarwin [ unstable.age-plugin-se ];
      };
  };
}
