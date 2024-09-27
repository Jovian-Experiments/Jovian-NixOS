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
        description = ''
          > Loosen the product_serial node to `440 / root:wheel`, rather than `400 / root:root`
          > to allow the physical users to read S/N without auth.
          — holo-dmi-rules 1.0
        '';
      };
      enableZram = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = ''
          Whether to enable SteamOS-like zram swap configuration
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
    (mkIf (cfg.enableZram) {
      # Match vendor settings: https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/holo-main/holo-zram-swap-0.1-0/zram-generator.conf
      zramSwap = {
        enable = lib.mkDefault true;
        priority = lib.mkDefault 100;
        memoryPercent = lib.mkDefault 50;
        algorithm = lib.mkDefault "zstd";
      };
    })
  ];
}
