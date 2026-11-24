{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.jovian.steamos;
in
{
  options = {
    jovian.steamos = {
      enableDefaultCmdlineConfig = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = ''
          Whether to enable SteamOS kernel command line flags.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enableDefaultCmdlineConfig) {
      boot.kernelParams = [
        # From grub-steamos in jupiter-hw-support
        #  - https://github.com/Jovian-Experiments/jupiter-hw-support/blob/08fc462bd0ce0f0c198a5aed36c0bf307fcfb326/etc/default/grub-steamos

        # Valve says:
        #
        # We set amdgpu.lockup_timeout in order to control the TDR for each ring
        # 0 (GFX): 5s (was 10s)
        # 1 (Compute): 10s (was 60s wtf)
        # 2 (SDMA): 10s (was 10s)
        # 3 (Video): 5s (was 10s)
        "amdgpu.lockup_timeout=5000,10000,10000,5000"

        # ttm.pages_min is set to 8GB in units of page size (4096), which is min
        # required for decent gaming performance.
        "ttm.pages_min=2097152"

        # These are presumably tweaked for perf reasons.
        "log_buf_len=4M"
        "amd_iommu=off"
        "audit=0"
      ];
    })
  ];
}
