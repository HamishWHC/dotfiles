{ self }:
self.lib.mkDarwinHost {
  name = "personal";
  username = "hamishwhc";
  manageUser = false;
}
