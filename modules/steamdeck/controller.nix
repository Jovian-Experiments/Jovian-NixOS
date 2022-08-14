{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableControllerUdevRules = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
            Enables udev rules to make the controller controllable by users.

            Without this, neither steam, nor any other userspace client can
            switch the controller from out of its default "lizard" mode.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enableControllerUdevRules) {
      # Necessary for the controller parts to work correctly.
      services.udev.extraRules = ''
        # This rule is needed by the vendor power-button-handler.py
        SUBSYSTEM=="input", ATTRS{phys}=="isa0060/serio0/input0", MODE="0660", TAG+="uaccess"
      '' + lib.optionalString (!config.hardware.steam-hardware.enable) ''
        # This rule is necessary for gamepad emulation.
        KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"

        # This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"

        # Valve HID devices over USB hidraw
        KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
      '';
    })
  ];
}
