{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
  ;
  cfg = config.jovian;
in
{
  options = {
    jovian = {
      enableEarlyModesetting = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
      enableFbconRotation = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
      enableXorgRotation = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.enableEarlyModesetting {
      boot.initrd.kernelModules = [
        "amdgpu"
      ];
    })
    (mkIf cfg.enableFbconRotation {
      boot.kernelParams = [
        "fbcon=rotate:1"
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
