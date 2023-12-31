{ config, lib, ... }:

# Misc. settings set-up by the hw-support package

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
    (mkIf (cfg.enable) {
      # Match vendor settings: https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/holo-main/holo-zram-swap-0.1-0/zram-generator.conf
      zramSwap = {
        enable = lib.mkDefault true;
        priority = lib.mkDefault 100;
        memoryPercent = lib.mkDefault 50;
        algorithm = lib.mkDefault "zstd";
      };
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
  ];
}
