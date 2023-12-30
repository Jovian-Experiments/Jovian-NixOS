{ config, lib, ... }:

let
  inherit (lib)
    mkDefault
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
      enableSysctlConfig = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = ''
          Whether to enable SteamOS sysctl configurations
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enableSysctlConfig) {
      boot.kernel.sysctl = {
        # From steamos-customizations-jupiter
        # https://github.com/Jovian-Experiments/steamos-customizations-jupiter/commit/bc978e8278ca29a884b1fe70cf2ec9e1e4ba05df
        "kernel.sched_cfs_bandwidth_slice_u" = mkDefault 3000;
        "kernel.sched_latency_ns" = mkDefault 3000000;
        "kernel.sched_min_granularity_ns" = mkDefault 300000;
        "kernel.sched_wakeup_granularity_ns" = mkDefault 500000;
        "kernel.sched_migration_cost_ns" = mkDefault 50000;
        "kernel.sched_nr_migrate" = mkDefault 128;
      };
    })
  ];
}
