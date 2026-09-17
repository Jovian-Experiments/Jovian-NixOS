{ lib, ... }:
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steamdeck" "enableControllerUdevRules" ]
      [ "jovian" "steamos" "enableControllerUdevRules" ])
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steamdeck" "enablePerfControlUdevRules" ]
      [ "jovian" "steamos" "enablePerfControlUdevRules" ])
    (lib.mkRenamedOptionModule
      [ "jovian" "devices" "steamdeck" "enableSoundSupport" ]
      [ "jovian" "steamos" "enableSoundSupport" ])
  ];
}
