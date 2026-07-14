{ inputs, ... }:
{
  flake.features.node.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      nodejs = pkgs.nodejs_26;

      corepackHome = "${config.xdg.dataHome}/corepack";
      baseCorepack = pkgs.corepack.overrideAttrs {
        buildInputs = [ nodejs ];
      };
      corepack = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = baseCorepack;
        exePath = "${baseCorepack}/bin/corepack";
        binName = "corepack";
        env.COREPACK_HOME = corepackHome;
      };

      # Declaratively generate the pnpm/yarn shims that `corepack enable` would
      # normally create. Running `corepack enable` at runtime fails because it
      # installs the shims next to the corepack binary (the read-only nix
      # store). Building them here instead puts them on PATH via home.packages,
      # keeping them in sync with the nodejs/corepack version.
      corepackShims = pkgs.runCommand "corepack-shims" { nativeBuildInputs = [ corepack ]; } ''
        mkdir -p "$out/bin"
        export COREPACK_HOME="$TMPDIR/corepack-home"
        mkdir -p "$COREPACK_HOME"
        ${corepack}/bin/corepack enable --install-directory "$out/bin" pnpm yarn
      '';
    in
    {
      home.packages = [
        nodejs
        corepack
        corepackShims
        pkgs.rustup
      ];

      # The generated shims exec corepack.cjs directly (not via the wrapper),
      # so expose COREPACK_HOME to the session too.
      home.sessionVariables.COREPACK_HOME = corepackHome;
    };
}
