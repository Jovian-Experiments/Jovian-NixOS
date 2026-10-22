{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
  hardware = config.jovian.hardware;
  steam = config.jovian.steam;
in
{
  options = {
    jovian.hardware.has.nonNativePaddles = mkOption {
    default = false;
    type = types.bool;
    description = ''
      Whether the device has extra buttons like rear paddles that aren't
      natively supported by the Linux kernel.
    '';
  };
  config = mkIf hardware.has.nonNativePaddles {
    services.handheld-daemon = {
      enable = steam.enable;
      user = steam.user;
    };
  };
}
