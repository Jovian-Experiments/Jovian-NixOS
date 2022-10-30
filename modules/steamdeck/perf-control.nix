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
      enablePerfControlUdevRules = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
          Whether to make performance-related device attributes controllable by users.

          The Steam Deck Client directly modifies several device attributes to
          control the display brightness and to enable performance tuning (TDP
          limit, GPU clock control).
        '';
      };
    };
  };
  config = mkIf (cfg.enablePerfControlUdevRules) {
    services.udev.extraRules = ''
      # Enables brightness slider in Steam
      # - /sys/class/backlight/amdgpu_bl0/brightness
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"

      # Enables manual GPU clock control in Steam
      # - /sys/class/drm/card0/device/power_dpm_force_performance_level
      # - /sys/class/drm/card0/device/pp_od_clk_voltage
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage"

      # Enables manual TDP limiter in Steam
      # - /sys/class/hwmon/hwmon*/power{1,2}_cap
      ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power1_cap /sys/%p/power2_cap"
    '';
  };
}
