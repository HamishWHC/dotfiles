{ self, ... }: {
  flake.profiles.workstation = [
    # Inherits from desktop profile
    self.profiles.desktop

    # IDE
    self.features.vscode

    # Runtimes and Language Tooling
    self.features.bun
    self.features.node
    self.features.go
    self.features.uv
    self.features.rust
    self.features.zig
    self.features.nix-tools
    self.features.docker

    # Cloud Tooling
    self.features.aws
    self.features.terraform
    self.features.kube
    self.features.aptakube

    # Misc
    self.features.cybersec
    self.features.ai
    self.features.lima
    self.features.just
  ];
}
