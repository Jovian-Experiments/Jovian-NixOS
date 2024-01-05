{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    optionalString
    types
  ;

  cfg = config.jovian.steam;
in
{
  options = {
    jovian.steam.updater = {
      splash = mkOption {
        type = types.enum [
          "steamos"
          "bgrt"
          "vendor"
        ];
        default = "steamos";
        description = lib.mdDoc ''
          Configures the source of the splash screen used by the updater (preloader) step when launching Steam.

          When `steamos`, this will use the vendor-selected image, scaled appropriately.

          When `bgrt`, the BGRT (UEFI vendor logo) will be used.

          When `vendor`, the vendor default will not be changed. This differs from `default` in that
          on systems other than the Steam Deck, the scaling may not be correct.

          > The scale of the vendor logo (in `vendor`) is incorrect when the display resolution
          > is different from 1280 pixels wide. The startup animation will use a smaller logo
          > than the one used in the updater step.
        '';
      };
    };
  };
  config = mkIf (cfg.enable && cfg.updater.splash != "vendor") (mkMerge [
    {
      environment.etc."xdg/gamescope-session/environment" = {
        text = lib.mkAfter ''
          if test -e /sys/firmware/acpi/bgrt/image; then
            (
              NATIVE_RES=$(cat /sys/class/drm/card*-eDP-*/modes | head -n1)

              ARGS=(
                ${pkgs.imagemagick}/bin/convert

                # On this empty image, with the panel-native resolution
                "canvas:black[$NATIVE_RES!]"
              )

              # drm_info will report the orientation this way:
              # │   │       └───"panel orientation" (immutable): enum {Normal, Upside Down, Left Side Up, Right Side Up} = Right Side Up
              ROTATE_SNIPPET=(
                # Rotate to the correct panel orientation
                -rotate $(
                  case "$(${pkgs.drm_info}/bin/drm_info | grep 'panel orientation' | head -n1 | cut -d'=' -f2)" in
                    *Right*Side*) echo '-90';;
                    *Left*Side*)   echo '90';;
                    *Upside*)     echo '180';;
                    *)              echo '0';;
                  esac
                )
              )

              ${optionalString (cfg.updater.splash == "steamos") ''
                ARGS+=(
                  # Rotate the canvas, only
                  "''${ROTATE_SNIPPET[@]}"

                  # Add the logo steam selected
                  "$ui_background"
                  # Centered
                  -gravity center
                  # (This means 'add')
                  -composite
                )
              ''}

              ${optionalString (cfg.updater.splash == "bgrt") ''
                ARGS+=(
                  # Add the BGRT (bmp image)
                  "/sys/firmware/acpi/bgrt/image"
                  # At its defined offset
                  -geometry +$(cat /sys/firmware/acpi/bgrt/xoffset)+$(cat /sys/firmware/acpi/bgrt/yoffset)
                  # (This means 'add')
                  -composite

                  # Rotate the BGRT and the canvas
                  # (BGRT will be in the panel-native orientation)
                  "''${ROTATE_SNIPPET[@]}"
                )
              ''}

              ARGS+=(
                # Ensures crop crops a single image with gravity
                -gravity center

                # As 16:9
                # Steam scales the image, whichever dimensions to a 16:9 aspect ratio.
                # A 800px high image on steam deck will be scaled to 720p size.
                -crop 16:9

                # To this path.
                "$XDG_RUNTIME_DIR/steam-splash.png"
              )
              "''${ARGS[@]}"
            )
            if test -e "$XDG_RUNTIME_DIR/steam-splash.png"; then
              export STEAM_UPDATEUI_PNG_BACKGROUND="$XDG_RUNTIME_DIR/steam-splash.png"
            else
              echo "Warning: steam-splash.png was not generated as expected... keeping auto-picked splash."
            fi
          fi
        '';
      };
    }
  ]);
}
