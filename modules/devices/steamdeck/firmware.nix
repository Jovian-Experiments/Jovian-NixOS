# BIOS/Firmware updates

{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkForce
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
      autoUpdate = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to automatically update the BIOS and controller firmware.
        '';
      };

      enableFwupdBiosUpdates = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        description = ''
          Whether to use fwupd to update the BIOS.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      jovian.overlay.enable = mkForce true;

      hardware.firmware = [
        (lib.hiPrio pkgs.linux-firmware-jupiter)
        (lib.hiPrio pkgs.steamdeck-dsp)
      ];
    })
    (mkIf (cfg.autoUpdate) {
      jovian.overlay.enable = mkForce true;

      systemd.packages = [pkgs.steamdeck-firmware];

      systemd.services.jupiter-biosupdate.wantedBy = ["multi-user.target"];
      systemd.services.jupiter-controller-update.wantedBy = ["multi-user.target"];
    })
    (mkIf (cfg.enableFwupdBiosUpdates) {
      jovian.overlay.enable = mkForce true;

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
