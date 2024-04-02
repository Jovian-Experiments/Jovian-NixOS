{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.services.opensd;
in
{
  options.services.opensd = {
    enable = mkEnableOption "opensd";

    package = mkOption {
      type = types.package;
      default = pkgs.opensd;
      defaultText = lib.literalExpression "pkgs.opensd";
      description = ''
        The OpenSD package to use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # OpenSD works using uinput
    hardware.uinput.enable = true;

    # See: https://codeberg.org/OpenSD/opensd/src/branch/master/systemd/opensd.service
    systemd.user.services.opensd = {
      description = "OpenSD Steam Deck userspace input driver daemon";
      wantedBy = [ "graphical-session.target" ];
      conflicts = [ "gamescope-session.service" ]; # Steam will fight over the input device
      unitConfig = {
        ConditionGroup = "uinput";
      };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/opensdd -l info";
      };
    };
  };
}
