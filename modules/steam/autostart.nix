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


      services.displayManager = {
        autoLogin = {
          enable = true;
          user = cfg.user;
        };
        sddm = {
          enable = true;
          autoLogin.relogin = true;
          # Valve uses the default X11 greeter, but ideally you'd never see it anyway
          # and the closure size impact is significantly less this way.
          wayland.enable = true;
        };
        defaultSession = "gamescope-wayland";
      };

      # replicate vendor failsafe in case the system is rebooted with a broken config
      systemd.services.display-manager.serviceConfig.ExecStartPre = "-${pkgs.coreutils}/bin/rm /etc/sddm.conf.d/zzt-steamos-temp-login.conf";

      # tell steamos-manager it's allowed to manage our session
      environment.etc."sddm.conf.d/holo.conf".text = "";

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

      systemd.user.services.steamos-manager-session-cleanup = {
        overrideStrategy = "asDropin";
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

        restartIfChanged = false;
      };


      xdg.portal.configPackages = mkDefault [ pkgs.gamescope-session ];
    })
  ]);
}
