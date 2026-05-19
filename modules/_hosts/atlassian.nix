{ self }:
self.lib.mkDarwinHost {
  name = "atlassian";
  username = "hcox";
  manageUser = false;
}
