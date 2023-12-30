{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.steamos;
in
{
  options = {
    jovian.steamos = {
      enableProductSerialAccess = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = lib.mdDoc ''
          > Loosen the product_serial node to `440 / root:wheel`, rather than `400 / root:root`
          > to allow the physical users to read S/N without auth.
          — holo-dmi-rules 1.0
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enableProductSerialAccess) {
      systemd.tmpfiles.rules = [
        "z /sys/class/dmi/id/product_serial 440 root wheel - -"
      ];
    })
  ];
}
