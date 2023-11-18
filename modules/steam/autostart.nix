{ config, lib, pkgs, ... }:

let
  inherit (lib)
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
          description = lib.mdDoc ''
            Whether to automatically launch the Steam Deck UI on boot.

            Traditional Display Managers cannot be enabled in conjunction with this option.
          '';
        };

        user = mkOption {
          type = types.str;
          description = lib.mdDoc ''
            The user to run Steam with.
          '';
        };

        desktopSession = mkOption {
          type = with types ; nullOr str // {         
            check = userProvidedDesktopSession:
              lib.assertMsg (userProvidedDesktopSession != null -> (str.check userProvidedDesktopSession && lib.elem userProvidedDesktopSession config.services.xserver.displayManager.sessionData.sessionNames)) ''
                  Desktop session '${userProvidedDesktopSession}' not found.
                  Valid values for 'jovian.steam.desktopSession' are:
                    ${lib.concatStringsSep "\n  " (lib.lists.remove "gamescope-wayland" config.services.xserver.displayManager.sessionData.sessionNames)}
                  If you don't want a desktop session to switch to, remove 'jovian.steam.desktopSession' from your config.
              '';
          };
          default = null;
          example = "plasma";
          description = lib.mdDoc ''
            The session to launch for Desktop Mode.

            By default, attempting to switch to the desktop will launch
            Gaming Mode again.
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

            Hint: check `services.xserver.displaymanager.*.enable` options in your configuration.
          '';
        }
      ];

      services.xserver = {
        enable = true;
        displayManager.lightdm.enable = false;
        displayManager.startx.enable = true;
      };

      systemd.user.services.gamescope-session = {
        overrideStrategy = "asDropin";

        environment = lib.mkForce {
          JOVIAN_DESKTOP_SESSION = cfg.desktopSession;
        };

        # upstream unit redirects to a file, but this seems unnecessary now?
        # see https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/76aa4a564094dc656aa1b1daa0f116a7b93b0d7b/gamescope-session.service#L10
        serviceConfig = {
          StandardOutput = "journal";
          StandardError = "journal";
        };
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            user = "jovian-greeter";
            command = "${pkgs.jovian-greeter}/bin/jovian-greeter ${cfg.user}";
          };
        };
      };

      users.users.jovian-greeter = {
        isSystemUser = true;
        group = "jovian-greeter";
      };
      users.groups.jovian-greeter = {};

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

      environment = {
        systemPackages = [ pkgs.jovian-greeter.helper ];
        pathsToLink = [ "lib/jovian-greeter" ];
      };
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            action.id == "org.freedesktop.policykit.exec" &&
            action.lookup("program") == "/run/current-system/sw/lib/jovian-greeter/consume-session" &&
            subject.user == "jovian-greeter"
          ) {
            return polkit.Result.YES;
          }
        });
      '';
    })
  ]);
}
