{
  flake.features.mac-mouse-fix = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        configPath = "${config.home.homeDirectory}/Library/Application Support/com.nuebling.mac-mouse-fix/config.plist";
        # Run tests on the setup scripts to ensure they are working correctly before using them in the activation scripts.
        setupSettings = pkgs.runCommand "setup-mac-mouse-fix-settings.py" { } ''
          ${pkgs.python3}/bin/python3 ${./test-settings.py} ${./setup-settings.py}
          cp ${./setup-settings.py} "$out"
        '';
        setupLicense = pkgs.runCommand "setup-mac-mouse-fix-license.py" { } ''
          ${pkgs.python3}/bin/python3 ${./test-license.py} ${./setup-license.py}
          cp ${./setup-license.py} "$out"
        '';
        # Compile a small Objective-C program to reload the app's settings after they have been updated.
        reloadSettings = pkgs.stdenv.mkDerivation {
          pname = "reload-mac-mouse-fix-settings";
          version = "1";
          src = ./reload-settings.m;
          dontUnpack = true;
          buildPhase = ''
            $CC -x objective-c -fobjc-arc -framework Foundation -framework CoreFoundation \
              "$src" -o reload-mac-mouse-fix-settings
          '';
          installPhase = ''
            mkdir -p "$out/bin"
            cp reload-mac-mouse-fix-settings "$out/bin/"
          '';
        };
      in
      lib.mkIf pkgs.stdenv.isDarwin {
        sops.secrets.mac-mouse-fix-license-key = {
          key = "mac_mouse_fix_license_key";
          mode = "0400";
        };

        # Run before linkGeneration so we can read the old symlinked config file before replacing it.
        home.activation.setupMacMouseFix =
          lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
            ''
              run ${pkgs.python3}/bin/python3 ${setupSettings} \
                ${./settings.json} \
                ${lib.escapeShellArg configPath} \
                '/Applications/Mac Mouse Fix.app/Contents/Resources/default_config.plist'
              run ${reloadSettings}/bin/reload-mac-mouse-fix-settings
            '';

        home.activation.activateMacMouseFix =
          lib.hm.dag.entryAfter
            [
              "setupMacMouseFix"
              "sops-nix"
              "linkGeneration"
            ]
            ''
              run ${pkgs.python3}/bin/python3 ${setupLicense} \
                ${lib.escapeShellArg configPath} \
                ${lib.escapeShellArg config.sops.secrets.mac-mouse-fix-license-key.path}
            '';
      };

    darwin = {
      homebrew.casks = [ "mac-mouse-fix" ];
    };
  };
}
