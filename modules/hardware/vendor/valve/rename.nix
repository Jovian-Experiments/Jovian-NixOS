{ lib, ... }:
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steamdeck" "enableControllerUdevRules" ]
      [ "jovian" "hardware" "vendor" "valve" "enableControllerUdevRules" ])
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steammachine" "enableControllerUdevRules" ]
      [ "jovian" "hardware" "vendor" "valve" "enableControllerUdevRules" ])
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steamdeck" "enablePerfControlUdevRules" ]
      [ "jovian" "hardware" "vendor" "valve" "enablePerfControlUdevRules" ])
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steammachine" "enablePerfControlUdevRules" ]
      [ "jovian" "hardware" "vendor" "valve" "enablePerfControlUdevRules" ])
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steamdeck" "enableSoundSupport" ]
      [ "jovian" "hardware" "vendor" "valve" "enableSoundSupport" ])
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steammachine" "enableSoundSupport" ]
      [ "jovian" "hardware" "vendor" "valve" "enableSoundSupport" ])
  ];
}
