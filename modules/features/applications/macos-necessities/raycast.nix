{
  flake.features.raycast.darwin = { lib, ... }: {
    homebrew.casks = [ "raycast" ];

    # Free Command-Space for Raycast, retaining the shortcut's existing binding.
    system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."64".enabled =
      lib.mkForce false;
  };
}
