{ config, lib, pkgs, ... }:

let
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableVendorRadv = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = ''
          Whether to enable the vendor branch of Mesa RADV.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enableVendorRadv {
    hardware.opengl = {
      extraPackages = [ pkgs.mesa-radv-jupiter.drivers ];
      extraPackages32 = [ pkgs.pkgsi686Linux.mesa-radv-jupiter.drivers ];
    };

    environment.etc."drirc".source = pkgs.mesa-radv-jupiter + "/share/drirc.d/00-radv-defaults.conf";
  };
}
