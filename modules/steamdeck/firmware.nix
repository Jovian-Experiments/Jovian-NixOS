# BIOS/Firmware updates

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
      enableFwupdBiosUpdates = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
          Whether to use fwupd to update the BIOS.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enableFwupdBiosUpdates) {
      services.fwupd.enable = true;

      environment.etc."fwupd/remotes.d/steamdeck-bios.conf".text = ''
        # Enabled by jovian.devices.steamdeck.enableFwupdBiosUpdates

        [fwupd Remote]
        Enabled=true
        Title=Steam Deck BIOS
        Keyring=none
        MetadataURI=file://${pkgs.steamdeck-bios-fwupd}
        ApprovalRequired=false
      '';
    })
  ];
}
