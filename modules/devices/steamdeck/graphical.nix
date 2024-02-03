{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
  ;
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableXorgRotation = lib.mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        type = lib.types.bool;
        description = ''
          Whether to rotate the display panel in X11.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enableXorgRotation {
      environment.etc."X11/xorg.conf.d/90-jovian.conf".text = ''
        Section "Monitor"
          Identifier     "eDP-1"
          Option         "Rotate"    "right"
        EndSection

        Section "InputClass"
          Identifier "Steam Deck main display touch screen"
          MatchIsTouchscreen "on"
          MatchDevicePath    "/dev/input/event*"
          MatchDriver        "libinput"

          # 90° Clock-wise
          Option "CalibrationMatrix" "0 1 0 -1 0 1 0 0 1"
        EndSection
      '';
    })
  ];
}
