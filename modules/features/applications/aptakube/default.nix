{
  flake.features.aptakube = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        licenseDirectory =
          if pkgs.stdenv.isDarwin then
            "${config.home.homeDirectory}/Library/Application Support/com.aptakube.Aptakube"
          else
            throw "Aptakube license setup: the Linux license path is not yet known; remove the Aptakube feature from this host until it is configured.";
        setupLicense = pkgs.writeShellApplication {
          name = "setup-aptakube-license";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.jq
          ];
          text = builtins.readFile ./setup-license.sh;
        };
      in
      {
        home.packages = [ pkgs.unstable.aptakube ];

        sops.secrets.aptakube-license-key = {
          key = "aptakube_license_key";
          mode = "0400";
        };

        home.activation.setupAptakubeLicense = lib.hm.dag.entryAfter [ "sops-nix" ] ''
          run ${lib.getExe setupLicense} \
            ${lib.escapeShellArg config.sops.secrets.aptakube-license-key.path} \
            ${lib.escapeShellArg licenseDirectory}
        '';
      };
  };
}
