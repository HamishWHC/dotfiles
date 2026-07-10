{
  flake-file.inputs = {
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
  };

  flake.modules.homeManager.vscode =
    {
      configDir,
      pkgs,
      ...
    }:
    let
      extensions = pkgs.nix-vscode-extensions.usingFixesFrom pkgs.unstable;
      shared = {
        enable = true;
        mutableExtensionsDir = false;
        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          extensions = with extensions.vscode-marketplace-release; [
            astro-build.astro-vscode
            bazelbuild.vscode-bazel
            bierner.github-markdown-preview
            bierner.markdown-checkbox
            bierner.markdown-emoji
            bierner.markdown-footnotes
            bierner.markdown-preview-github-styles
            bierner.markdown-shiki
            bierner.markdown-yaml-preamble
            bradlc.vscode-tailwindcss
            charliermarsh.ruff
            christian-kohler.path-intellisense
            dangmai.workspace-default-settings
            esbenp.prettier-vscode
            foxundermoon.shell-format
            github.vscode-github-actions
            golang.go
            hashicorp.hcl
            hashicorp.terraform
            jnoortheen.nix-ide
            matthewpi.caddyfile-support
            mechatroner.rainbow-csv
            mhutchie.git-graph
            ms-azuretools.vscode-containers
            ms-kubernetes-tools.vscode-kubernetes-tools
            ms-python.debugpy
            ms-python.python
            ms-python.vscode-pylance
            ms-python.vscode-python-envs
            ms-vscode-remote.remote-ssh-edit
            ms-vscode.hexeditor
            ms-vscode.live-server
            myriad-dreamin.tinymist
            oven.bun-vscode
            oxc.oxc-vscode
            pflannery.vscode-versionlens
            pkief.material-icon-theme
            redhat.java
            redhat.vscode-yaml
            rust-lang.rust-analyzer
            tamasfe.even-better-toml
            thedangander.jsonl-lab
            tomoki1207.pdf
            typescriptteam.native-preview
            vitest.explorer
            yoavbls.pretty-ts-errors
            ziyasal.vscode-open-in-github
          ];
        };
      };
    in
    {
      programs.vscode.enable = true;
      programs.vscode.package = pkgs.unstable.vscode;
      programs.vscodium = shared;
      programs.zsh.shellAliases.cdf = "code ${configDir}";
    };
}
