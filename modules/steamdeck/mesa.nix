{ config, lib, pkgs, ... }:

let
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableVendorMesa = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = ''
          Whether to enable the vendor branch of Mesa.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enableVendorMesa {
    hardware.opengl = {
      package = pkgs.mesa-jupiter.drivers;
      package32 = pkgs.pkgsi686Linux.mesa-jupiter.drivers;
    };

    environment.etc."drirc".source = pkgs.mesa-jupiter + "/share/drirc.d/00-radv-defaults.conf";
  };
}
