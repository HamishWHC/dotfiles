{ self, ... }:
{
  flake.modules.homeManager.workstation =
    { pkgs, ... }:
    {
      imports = [
        self.modules.homeManager.runtimes
        self.modules.homeManager.ghostty
        self.modules.homeManager.vscode
        self.modules.homeManager.nix-tools
      ];

      home.packages = with pkgs; [
        ghidra
      ];
    };
}
