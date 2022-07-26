{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;

  # Turn it off and on again
  steamdeck-controller-reset = pkgs.writeShellScript "steamdeck-controller-reset" ''
    echo 0 > /sys/devices/pci0000:00/0000:00:08.1/0000:04:00.4/usb3/3-3/authorized
    sleep 0.5
    echo 1 > /sys/devices/pci0000:00/0000:00:08.1/0000:04:00.4/usb3/3-3/authorized
    sleep 0.5
  '';
in
{
  options = {
    jovian = {
      enableControllerUdevRules = mkOption {
        type = types.bool;
        default = true;
        description = ''
            Enables udev rules to make the controller controllable by users.

            Without this, neither steam, nor any other userspace client can
            switch the controller from out of its default "lizard" mode.
        '';
      };
      enableControllerReset = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enables workaround that forcibly resets the Steam Deck controller
          when steam starts.

          This may be necessary if it is left in a bad state.

          This is enabled by default, as there's no reason not to harden the
          steam client launch.
        '';
      };
      controller = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enables the Jovian Controller input userspace service.
          '';
        };
      };
    };
  };
  config = mkMerge [
    (mkIf config.jovian.enableControllerUdevRules {
      # Necessary for the controller parts to work correctly.
      services.udev.extraRules = ''
        # This rule is necessary for gamepad emulation.
        KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"

        # This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

        # Valve HID devices over USB hidraw
        KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
      '';
    })
    (mkIf config.jovian.controller.enable {
      jovian.enableControllerUdevRules = true;
      systemd.user.services."Jovian-Controller" = {
        enable = true;
        serviceConfig = {
          Restart = "always";
          ExecStart = "${pkgs.jovian-controller}/bin/Jovian-Controller";
        };
        unitConfig = {
          ConditionPathExists = "/run/user/%U";
        };
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
      };
      # Configures the steam service to conflict and restart the
      # Jovian-Controller service.
      systemd.user.services."steam" = mkIf config.jovian.steam.enable {
        conflicts = [ "Jovian-Controller.service" ];
        serviceConfig = {
          ExecStopPost = "systemctl --user start Jovian-Controller.service";
        };
      };
    })
    (mkIf config.jovian.enableControllerReset {
      security.sudo.extraRules = [
        {
          groups = [ "users" ];
          commands = [
            { command = "${steamdeck-controller-reset}"; options = [ "NOPASSWD" ]; }
          ];
        }
      ];
      systemd.user.services."steam" = mkIf config.jovian.steam.enable {
        serviceConfig = {
          ExecStartPre = "/run/wrappers/bin/sudo ${steamdeck-controller-reset}";
        };
      };
    })
  ];
}
