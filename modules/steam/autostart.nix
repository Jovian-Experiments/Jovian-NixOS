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
    (mkIf cfg.autoStart {
      assertions = [
        {
          assertion = !config.systemd.services.display-manager.enable;
          message = ''
            Traditional Display Managers cannot be enabled when jovian.steam.autoStart is used

            Hint: check `services.displayManager.*.enable` options in your configuration.
          '';
        }
      ];

      warnings = lib.optional (cfg.desktopSession == null) ''
        jovian.steam.desktopSession is unset.

        This means that using the Switch to Desktop function in Gaming Mode will
        relaunch Gaming Mode.

        Set jovian.steam.desktopSession to the name of a desktop session, or "gamescope-wayland"
        to keep this behavior.
      '';

      services.displayManager.enable = true;

      systemd.user.services.gamescope-session = {
        overrideStrategy = "asDropin";

        environment = mkMerge (
          [
            {
              JOVIAN_DESKTOP_SESSION = cfg.desktopSession;
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

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            user = "root";
            command = "${pkgs.jovian-greeter}/bin/jovian-greeter ${cfg.user}";
          };
        };
        greeterManagesPlymouth = true;
      };

      # We handle this ourselves in the greeter
      systemd.services.plymouth-quit.enable = false;

      security.pam.services = {
        greetd.text = ''
          auth      requisite     pam_nologin.so
          auth      sufficient    pam_succeed_if.so user = ${cfg.user} quiet_success
          auth      required      pam_unix.so

          account   sufficient    pam_unix.so

          password  required      pam_deny.so

          session   optional      pam_keyinit.so revoke
          session   include       login
        '';
      };

      security.wrappers.jovian-consume-session = {
        source = "${pkgs.jovian-greeter.helper}/bin/consume-session";
        owner = cfg.user;
        group = "users";
        setuid = true;
      };

      xdg.portal.configPackages = mkDefault [ pkgs.gamescope-session ];
    })
  ]);
}
