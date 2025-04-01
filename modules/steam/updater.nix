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
          "jovian"
          "bgrt"
          "vendor"
        ];
        default = "steamos";
        description = ''
          Configures the source of the splash screen used by the updater (preloader) step when launching Steam.

          When `steamos`, this will use the vendor-selected image, scaled appropriately.

          When `jovian`, this will use the Jovian Experiments logo, scaled appropriately.

          When `bgrt`, the BGRT (UEFI vendor logo) will be used.

          When `vendor`, the vendor default will not be changed. This differs from `default` in that
          on systems other than the Steam Deck, the scaling may not be correct.

          > The scale of the vendor logo (in `vendor`) is incorrect when the display resolution
          > is different from 1280 pixels wide. The updater logo will be bigger than the one
          > used in the startup animation.
        '';
      };
    };
  };
  config = mkIf (cfg.enable && cfg.updater.splash != "vendor") (mkMerge [
    {
      systemd.services."jovian-updater-logo-helper" = {
        enable = true;
        unitConfig.ConditionPathIsDirectory = "/run";
        before = [ "display-manager.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          # Ignore errors (`set -e` is added helpfully for us)
          set +e

          # Except we want to fail early still...
          (
          set -e
          mkdir -p /run/jovian

          ${optionalString (cfg.updater.splash == "steamos") ''
            # NOTE: keep in sync with the conventions from `gamescope-session`.
            # (IMO downstream should rely on the BGRT instead...)
            # https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/92e7fe11493915a23745e96e78ecac87af0c1a02/gamescope-session#L162-L175
            board_name=$(cat /sys/class/dmi/id/board_name)
            if [[ $board_name = "Galileo" ]]; then
              ui_background=${pkgs.steamdeck-hw-theme}/share/plymouth/themes/steamos/steamos-galileo.png
            else
              ui_background=${pkgs.steamdeck-hw-theme}/share/plymouth/themes/steamos/steamos-jupiter.png
            fi

            jovian_updater_logo="$ui_background"
          ''}
          ${optionalString (cfg.updater.splash == "jovian") ''
            jovian_updater_logo="${../../artwork/logo/splash.png}"
          ''}
          ${optionalString (cfg.updater.splash == "bgrt") ''
            jovian_updater_logo="--bgrt"
          ''}

          ${pkgs.jovian-updater-logo-helper}/bin/jovian-updater-logo-helper "$jovian_updater_logo" "/run/jovian/steam-splash.png"
          )

          # Ensure this always terminates successfully, even if the logo thing failed
          true
        '';
      };
      environment.etc."xdg/gamescope-session/environment" = {
        text = lib.mkAfter ''
          # Actually tell the session to use the splash we just made. If it was made.
          if test -e "/run/jovian/steam-splash.png"; then
            export STEAM_UPDATEUI_PNG_BACKGROUND="/run/jovian/steam-splash.png"
          else
            echo "Warning: steam-splash.png was not generated as expected... keeping auto-picked splash."
          fi
        '';
      };
    }
  ]);
}
