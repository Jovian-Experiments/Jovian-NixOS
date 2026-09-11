# BIOS updates
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
  cfg = config.jovian.devices.steammachine;
in
{
  options = {
    jovian.devices.steammachine = {
      enableFwupdBiosUpdates = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steammachine.enable";
        description = ''
          Whether to use fwupd to update the BIOS.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      hardware.firmware = [
        (lib.hiPrio pkgs.linux-firmware-jupiter)
      ];
    })
    (mkIf (cfg.enableFwupdBiosUpdates) {
      services.fwupd.enable = true;

      # Valve's CABs are signed against SteamOS' fwupd keyring, not nixpkgs'.
      environment.etc."fwupd/remotes.d/fremont-vendor-directory.conf".text = ''
        # Enabled by jovian.devices.steammachine.enableFwupdBiosUpdates

        [fwupd Remote]
        Enabled=true
        Title=Fremont HW Support Updates
        Keyring=none
        MetadataURI=file://${pkgs.fremont-hw-support}/share/fwupd/remotes.d/fremont/firmware
        ApprovalRequired=false
      '';
    })
  ];
}
