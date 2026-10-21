{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableDeviceDataWorkarounds = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        description = ''
          Whether to add some workarounds for (Steam Deck) device-specific data.
        '';
        # Don't expose to users.
        internal = true;
        readOnly = true;
      };

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
    (mkIf (cfg.enableDeviceDataWorkarounds) {
      # z - adjust permissions
      systemd.tmpfiles.settings."99-jovian"."/sys/firmware/dmi/tables/*".z.mode = "444";
    })
    (mkIf (cfg.enableXorgRotation) {
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
          Option "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
        EndSection
      '';
    })
  ];
}
