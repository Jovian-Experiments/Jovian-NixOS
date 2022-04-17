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
      enableControllerUdevRules = mkOption {
        type = types.bool;
        default = true;
        description = ''
            Enables udev rules to make the controller controllable by users.

            Without this, neither steam, nor any other userspace client can
            switch the controller from out of its default "lizard" mode.
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
  ];
}
