{ self, ... }: {
  flake.profiles.workstation = [
    # Desktop Apps
    self.features.vscode
    self.features.ghostty

    # Runtimes and Language Tooling
    self.features.bun
    self.features.node
    self.features.go
    self.features.uv
    self.features.rust
    self.features.zig
    self.features.nix-tools
    self.features.docker

    # Pentest Tools
    self.features.ghidra

    # oh boy ai time
    self.features.ai
  ];
}
