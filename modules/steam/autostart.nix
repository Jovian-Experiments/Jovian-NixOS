{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.steam;
in
{
  options = {
    jovian = {
      steam = {
        autoStart = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to automatically launch the Steam Deck UI on boot.

            Traditional Display Managers cannot be enabled in conjunction with this option.
          '';
        };

        user = mkOption {
          type = types.str;
          description = ''
            The local system user that Steam will be launched as.
          '';
        };

        desktopSession = mkOption {
          type = with types ; nullOr str // {         
            check = userProvidedDesktopSession:
              lib.assertMsg (userProvidedDesktopSession != null -> (str.check userProvidedDesktopSession && lib.elem userProvidedDesktopSession config.services.displayManager.sessionData.sessionNames)) ''
                  Desktop session '${userProvidedDesktopSession}' not found.
                  Valid values for 'jovian.steam.desktopSession' are:
                    ${lib.concatStringsSep "\n  " config.services.displayManager.sessionData.sessionNames}
                  If you don't want a desktop session to switch to, set 'jovian.steam.desktopSession' to 'gamescope-wayland'.
              '';
          };
          default = null;
          example = "plasma";
          description = ''
            The session to launch for Desktop Mode.

            By default, attempting to switch to the desktop will launch Gaming Mode again.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      warnings = lib.optional (!cfg.autoStart && cfg.desktopSession != null) ''
        jovian.steam.desktopSession has no effect if jovian.steam.autoStart is disabled.

        Either enable jovian.steam.autoStart, or remove the desktopSession setting.
      '';
    }

    (mkIf cfg.autoStart {
      warnings = lib.optional (cfg.desktopSession == null) ''
        jovian.steam.desktopSession is unset.

        This means that using the Switch to Desktop function in Gaming Mode will
        relaunch Gaming Mode.

        Set jovian.steam.desktopSession to the name of a desktop session, or "gamescope-wayland"
        to keep this behavior.
      '';

      # Disable NixOS's autologin config generation.
      # We put autologin config in sddm.conf.d instead so that steamos-manager's
      # zzt-steamos-temp-login.conf can override the session on Switch to Desktop.
      # (SDDM reads conf.d files alphabetically, so zzt > 00)
      services.displayManager = {
        autoLogin.enable = lib.mkForce false;
        sddm.enable = true;
      };

      environment.etc."sddm.conf.d/00-jovian-autologin.conf".text = ''
        [Autologin]
        User=${cfg.user}
        Relogin=true
        Session=gamescope-wayland.desktop
      '';

      # Sentinel file: tell steamos-manager it's allowed to manage our session
      # Without it, the SessionManagement1 D-Bus interface
      # (Switch to Desktop/Game Mode) is not registered.
      environment.etc."sddm.conf.d/steamos.conf".text = "";

      # Steam overrides this SOMETIMES seemingly for no reason
      # so we need to force it back to the user's choice.
      systemd.user.services.jovian-setup-desktop-session = {
        wants = [ "steamos-manager.service" ];
        after = [ "steamos-manager.service" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.steamos-manager}/bin/steamosctl set-default-desktop-session ${cfg.desktopSession}.desktop";
        };

        wantedBy = [ "graphical-session.target" ];
      };

      systemd.user.services.gamescope-session = {
        overrideStrategy = "asDropin";

        environment = mkMerge (
          [
            {
              PATH = lib.mkForce null;
            }
          ]
          # Add any globally defined well-known XKB_DEFAULT environment variables to the session
          # This is the closest wayland sessions have to generic keyboard configurations.
          ++ (map (var:
            (mkIf (config.environment.variables ? "${var}") {
              "${var}" = mkDefault config.environment.variables."${var}";
            })
          ) [
              "XKB_DEFAULT_LAYOUT"
              "XKB_DEFAULT_OPTIONS"
              "XKB_DEFAULT_MODEL"
              "XKB_DEFAULT_RULES"
              "XKB_DEFAULT_VARIANT"
            ]
          )
        );
      };

      xdg.portal.configPackages = mkDefault [ pkgs.gamescope-session ];
    })
  ]);
}
