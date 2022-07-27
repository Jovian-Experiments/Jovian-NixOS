{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
  # ¯\_(ツ)_/¯
  token = "steampal_stable_9a24a2bf68596b860cb6710d9ea307a76c29a04d";

  # This script is used to hijack the call to `dbus-send` that the steam client
  # will to to return to the desktop.
  dbus-hijacker = (pkgs.writeShellScriptBin "dbus-send" ''
    if echo "$@" | grep 'DisplayManager.*SwitchToUser.*doorstop.*plasma'; then
      systemctl --user stop steam.target
      exit 0
    fi

    # Snitches on unhandled calls to `dbus-send`
    # echo dbus-send "$@" >> ~/dbus-hijacker.log

    exec ${pkgs.dbus}/bin/dbus-send "$@"
  '').overrideAttrs({ meta, ... }: { meta = meta // { piority = 9999; }; });

  steam = pkgs.steam.override {
    extraPkgs = pkgs: [ dbus-hijacker ];
  };
in
{
  options = {
    jovian = {
      steam = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enables stopped-by-default systemd service to launch steam
            in "PAL" user interface (steam deck interface).

            Use `systemctl --user start steam.target` to launch.

            Use `systemctl --user stop steam.target` to stop.
          '';
        };
      };
    };
  };
  config = mkMerge [
    (mkIf config.jovian.steam.enable {
      hardware.opengl.driSupport32Bit = true;
      hardware.pulseaudio.support32Bit = true;

      systemd.user.services."steam" = {
        enable = true;
        serviceConfig = {
          Restart = "always";
          ExecStart = pkgs.writeShellScript "steam-pal-ui" ''
            export PATH="${lib.makeBinPath ([
              pkgs.gamescope
              steam
            ])}:$PATH"
            # This forces the user in the steampal beta.
            # Not ideal, as it's not reversed by disabling this service.
            echo "${token}" > ~/.local/share/Steam/package/beta
            exec gamescope \
              --fullscreen \
              --steam \
              -- steam -steamos -gamepadui -pipewire-dmabuf
          '';
        };
        unitConfig = {
          ConditionPathExists = "/run/user/%U";
        };
        requisite = [ "steam.target" ];
        bindsTo = [ "steam.target" ];
      };
      # This target is used to manage the "dependency" on running steam.
      # Using `Upholds` here means the steam service will actually be
      # restarted if it has been killed, or exited otherwise.
      # Without this, `pkill gamescope` would not restart the service
      # even though it declared `Restart=always`.
      # ¯\_(ツ)_/¯
      # Though, in a way it makes more sense to have a *target* here
      # than a service.
      systemd.user.targets."steam" = {
        unitConfig = {
          Upholds = [ "steam.service" ];
        };
        enable = true;
        # wantedBy is not used, as this would make it a hard
        # requirement on the graphical session.
        # This service is only used to manage (start/stop) steam.
        requisite = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
      };
    })
  ];
}
