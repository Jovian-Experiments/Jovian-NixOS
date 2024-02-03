{ config, ... }:

{
  services.getty.autologinUser = config.jovian.steam.user;
}
