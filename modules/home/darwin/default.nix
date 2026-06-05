{
  flake.modules.homeManager.darwin = {
    home.file."Library/Application Support/com.nuebling.mac-mouse-fix/config.plist".source =
      ./mac-mouse-fix.plist;
  };
}
