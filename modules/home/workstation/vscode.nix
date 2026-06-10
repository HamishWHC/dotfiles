{
  flake.modules.homeManager.vscode =
    { configDir, ... }:
    {
      programs.vscode.enable = true;
      programs.zsh.shellAliases.cdf = "code ${configDir}";
    };
}
