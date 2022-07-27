{ config, lib, pkgs, ... }:

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
      enableEarlyModesetting = lib.mkOption {
        default = cfg.enable;
        type = lib.types.bool;
      };
      enableDRMRotationParam = lib.mkOption {
        default = !cfg.hasKernelPatches;
        type = lib.types.bool;
      };
      enableXorgRotation = lib.mkOption {
        default = cfg.enable;
        type = lib.types.bool;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enableEarlyModesetting {
      boot.initrd.kernelModules = [
        "amdgpu"
      ];
    })
    (mkIf cfg.enableDRMRotationParam {
      boot.kernelParams = [
        "video=eDP-1:panel_orientation=right_side_up"
      ];
    })
    (mkIf cfg.enableXorgRotation {
      environment.etc."X11/xorg.conf.d/90-jovian.conf".text = ''
        Section "Monitor"
          Identifier     "eDP"
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
