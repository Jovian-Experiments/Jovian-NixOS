{ config, lib, pkgs, ... }:

# Misc. settings set-up by the hw-support package

let
  inherit (lib)
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
      enableAutoMountUdevRules = mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        type = types.bool;
        description = ''
          Whether to enable udev rules to automatically mount SD cards upon insertion.
        '';
      };
      enableDefaultCmdlineConfig = mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        type = types.bool;
        description = ''
          Whether to enable Steam Deck command line flags.
        '';
      };
      enableDefaultStage1Modules = mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        type = types.bool;
        description = ''
          Whether to enable essential kernel modules in initrd.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enableAutoMountUdevRules) {
      services.udev.packages = [
        pkgs.jupiter-hw-support
      ];
    })
    (mkIf (cfg.enableDefaultStage1Modules) {
      boot.initrd.kernelModules = [
        "hid-generic"

        # Touch
        "hid-multitouch"
        "i2c-designware-core"
        "i2c-designware-platform"
        "i2c-hid-acpi"

        # Gamepad
        "usbhid"
      ];
      boot.initrd.availableKernelModules = [
        "nvme"
        "sdhci"
        "sdhci_pci"
        "cqhci"
        "mmc_block"
      ];
    })
    (mkIf (cfg.enableDefaultCmdlineConfig) {
      boot.kernelParams = [
        # From grub-steamos in jupiter-hw-support
        #  - https://github.com/Jovian-Experiments/jupiter-hw-support/blob/jupiter-20231212.1/etc/default/grub-steamos
        "spi_amd.speed_dev=1"
      ];
    })
    (mkIf (config.jovian.hardware.amd.gpu.enableBacklightControl) {
      # Galileo specific rules for brightness control
      services.udev.extraRules = ''
        # - /sys/devices/platform/AMDI0010:02/i2c-2/i2c-ANX7580A:00/{brightness,bmode} (Galileo)
        ACTION=="add", SUBSYSTEM=="i2c", KERNEL=="i2c-ANX7580A:00", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/brightness /sys/%p/bmode"
      '';
    })
  ];
}
