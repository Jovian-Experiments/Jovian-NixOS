{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.steamos;
in
{
  options.jovian.steamos.enableEarlyOOM = mkOption {
    default = cfg.useSteamOSConfig;
    defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
    type = types.bool;
    description = ''
      Enable SteamOS-like earlyoom config.
    '';
  };

  config = mkIf (cfg.enableEarlyOOM) {
    # Match vendor settings: https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/holo-main/holo-earlyoom/holo-earlyoom.systemd.conf
    services.earlyoom = {
      enable = lib.mkDefault true;
      extraArgs = lib.mkDefault [ "-M" "409600,307200" "-S" "409600,307200" ];
    };
  };
}
