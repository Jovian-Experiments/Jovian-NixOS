{ config, lib, ... }:
let
  ledAttrs = [
    "brightness"
    "brightness_scale"
    "brightness_startup"
    "effect"
    "enabled"
    "mode"
    "multi_intensity"
    "multi_intensity_startup"
    "profile"
    "speed"
    "delay"
    "trigger"
    "delay_on"
    "delay_off"
    "led_brightness_multiplier"
  ];

  inherit (lib)
    mkIf
    mkOption
    types
    ;
  cfg = config.jovian.devices.steammachine;
in
{
  options = {
    jovian.devices.steammachine = {
      enableLightbarControl = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steammachine.enable";
        description = ''
          Whether to loosen access permissions on LED devices to allow for lightbar controls via Steam.
        '';
      };
    };
  };
  config = mkIf cfg.enableLightbarControl {
    systemd.tmpfiles.rules = map (attr: "z /sys/class/leds/*/${attr} 0660 root users - -") ledAttrs;
  };
}
