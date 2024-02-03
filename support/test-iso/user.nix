{ config, ... }:

{
  users.users = {
    "${config.jovian.steam.user}" = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "audio"
        "networkmanager"
        "video"
        "wheel"
      ];
      initialHashedPassword = "TEST_PASSWORD_DO_NOT_USE";
    };
    root = {
      initialHashedPassword = "TEST_PASSWORD_DO_NOT_USE";
    };
  };
  security.sudo.wheelNeedsPassword = false;
}
