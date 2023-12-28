{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
  ;
  cfg = config.jovian.decky-loader.plugins.jovian-annoyances;

  jovian-annoyances-plugin = pkgs.callPackage ./plugin.nix { configuration = cfg; };
in
{
  options = {
    jovian.decky-loader = {
      plugins.jovian-annoyances = {
        enable = mkEnableOption "the Jovian Annoyances decky plugin";
        features = {
          timeZone = {
            enable = mkOption {
              type = types.bool;
              default = config.time.timeZone != null;
              defaultText = lib.literalExpression "config.time.timeZone != null";
              description = ''
                When enabled, forces the timezone selection to the only available timezone, with the given strings.
              '';
            };
            utcOffset = mkOption {
              type = types.strMatching "^(0|-?[0-9]{3,4})$";
              default = "9999";
              example = "-500";
              description = ''
                UTC Timezone offset [sic] to use.
              '';
            };
            timeZoneName = mkOption {
              type = types.str;
              default = config.time.timeZone;
              defaultText = lib.literalExpression "config.time.timeZone";
              example = "Eastern Standard Time (Montréal)";
              description = ''
                Timezone name to use.
              '';
            };
            regionName = mkOption {
              type = types.str;
              default = "(Configured via NixOS settings)";
              example = "Toronto, Montréal";
              description = ''
                Region name to use.
              '';
            };
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d  ${config.jovian.decky-loader.stateDir}/plugins 755 ${config.jovian.decky-loader.user} decky -"
      "L+ ${config.jovian.decky-loader.stateDir}/plugins/jovian-annoyances  - - - -  ${jovian-annoyances-plugin}"
    ];
  };
}
