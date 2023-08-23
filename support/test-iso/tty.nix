{ config, lib, pkgs, ... }:

{
  services.getty.autologinUser = config.jovian.steam.user;
}
