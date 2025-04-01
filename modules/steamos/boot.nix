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

        # ttm.pages_min is set to 8GB in units of page size (4096), which is min
        # required for decent gaming performance.
        # amdgpu.sched_hw_submission is set to 4 to avoid bubbles of lack-of work
        # with the default (2).
        # 4 is the maximum that is supported across RDNA2 + RDNA3.
        # Any more results in a hang at startup on RDNA3.
        "log_buf_len=4M"
        "amd_iommu=off"
        "amdgpu.lockup_timeout=5000,10000,10000,5000"
        "ttm.pages_min=2097152"
        "amdgpu.sched_hw_submission=4"
        "audit=0"
        # Jovian: intentionally not using this one, as many people run
        # setups with LUKS password prompts on fbcon
        # "fbcon=vc:4-6"
        # Jovian: this is Steam Deck specific so it goes into the Deck profile
        # "fbcon=rotate:1"
      ];
    })
  ];
}
