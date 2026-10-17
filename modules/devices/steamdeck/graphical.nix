{
  config,
  lib,
  pkgs,
  ...
}:

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

      enableVendorDrivers = lib.mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression;
        type = lib.types.bool;
        description = ''
          Whether to use Valve's branches of drivers instead of upstream Mesa.

          These drivers may include additional fixes, but are not validated
          on non-Steamdeck hardware.
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
          Option "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
        EndSection
      '';
    })

    (mkIf cfg.enableVendorDrivers {
      hardware.graphics = {
        package = pkgs.jovianPackages.mesa-radeonsi;
        package32 = pkgs.pkgsi686Linux.jovianPackages.mesa-radeonsi;
        extraPackages = [ (lib.hiPrio pkgs.jovianPackages.mesa-radv) ];
        extraPackages32 = [ (lib.hiPrio pkgs.pkgsi686Linux.jovianPackages.mesa-radv) ];
      };

      environment.etc."drirc".source =
        pkgs.jovianPackages.mesa-radv + "/share/drirc.d/00-radv-defaults.conf";
    })
  ];
}
