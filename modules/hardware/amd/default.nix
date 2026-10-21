{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.jovian.hardware.amd;
  hardware = config.jovian.hardware;
  mkHasOption =
    description:
    mkOption {
      default = false;
      type = types.bool;
      description = ''
        Whether the device has ${description}.
      '';
    };
in
{
  options = {
    jovian.hardware.has.amd.gpu = mkHasOption "an AMD GPU";
    jovian.hardware.amd = {
      gpu = {
        enableEarlyModesetting = mkOption {
          default = hardware.has.amd.gpu;
          defaultText = lib.literalExpression "config.jovian.hardware.has.amd.gpu";
          type = lib.types.bool;
          description = ''
            Whether to enable early kernel modesetting.
          '';
        };
        enableBacklightControl = mkOption {
          default = hardware.has.amd.gpu;
          defaultText = lib.literalExpression "config.jovian.hardware.has.amd.gpu";
          type = lib.types.bool;
          description = ''
            Whether to loosen access to the backlight device nodes.

            Required for brightness controls in Steam.
          '';
        };
        enableUserspacePerfControl = mkOption {
          default = hardware.has.amd.gpu;
          defaultText = lib.literalExpression "config.jovian.hardware.has.amd.gpu";
          type = lib.types.bool;
          description = ''
            Whether to loosen access to performance/power tuning nodes from userspace.

            Required for performance controls in Steam Big Picture mode.
          '';
        };
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.gpu.enableEarlyModesetting {
      boot.initrd.kernelModules = [
        "amdgpu"
      ];
      # Firmware is required in stage-1 for early KMS.
      hardware.enableRedistributableFirmware = true;
    })
    (mkIf (cfg.gpu.enableBacklightControl) {
      # Enables brightness slider in Steam
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
      '';
    })
    (mkIf (cfg.gpu.enableUserspacePerfControl) {
      services.udev.extraRules = ''
        # Enables manual GPU clock control in Steam
        # - /sys/class/drm/card0/device/power_dpm_force_performance_level
        # - /sys/class/drm/card0/device/pp_od_clk_voltage
        ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage"

        # Enables manual TDP limiter in Steam
        # - /sys/class/hwmon/hwmon*/power{1,2}_cap
        ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power1_cap /sys/%p/power2_cap"
      '';
    })
  ];
}
