{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
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

            Use `systemctl --user start steam` to launch.

            Use `systemctl --user stop steam` to stop.
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
          KillMode = "process";
          Restart = "always";
          RestartSec = "1";
          ExecStart = pkgs.writeShellScript "steam-pal-ui" ''
            export PATH="$PATH:${lib.makeBinPath (with pkgs;[
              gamescope
              steam
            ])}"
            exec gamescope \
              --fullscreen \
              --steam \
              -- steam -gamepadui -pipewire-dmabuf
          '';
        };
        unitConfig = {
          ConditionPathExists = "/run/user/%U";
        };
        # wantedBy is not used, as this would make it a hard
        # requirement on the graphical session.
        # This service is only used to manage (start/stop) steam.
        requisite = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
      };
    })
  ];
}
