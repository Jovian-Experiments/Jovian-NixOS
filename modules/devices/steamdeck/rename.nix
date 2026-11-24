{ lib, ... }:
{
  imports = [
    (lib.mkRenamedOptionModule # device fan control
      [ "jovian" "devices" "steamdeck" "enableOsFanControl" ]
      [ "jovian" "hardware" "valve" "fan-control" "enable" ]
    )
    (lib.mkRenamedOptionModule # Steam-deck dsp
      [ "jovian" "devices" "steamdeck" "enableSoundSupport" ]
      [ "jovian" "hardware" "valve" "steamdeck-dsp" "enable" ]
    )
    (lib.mkRenamedOptionModule # steamos performance controls
      [ "jovian" "devices" "steamdeck" "enablePerfControlUdevRules" ]
      [ "jovian" "hardware" "amd" "gpu" "enableUserspacePerfControl" ]
    )
    (lib.mkRenamedOptionModule # steamos vendor kernel + patches
      [ "jovian" "devices" "steamdeck" "enableKernelPatches" ]
      [ "jovian" "steamos" "enableVendorKernel" ]
    )
    (lib.mkRenamedOptionModule # mesa
      [ "jovian" "devices" "steamdeck" "enableVendorDrivers" ]
      [ "jovian" "steamos" "enableVendorMesa" ]
    )
    (lib.mkRemovedOptionModule # controller udev rules
      [ "jovian" "devices" "steamdeck" "enableControllerUdevRules" ]
      "These udev rules are now included in steam-devices-udev-rules, drop the option from your configuration."
    )
  ];
}
