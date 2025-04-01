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
  mkJovianDefault = lib.mkOverride 999;
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
        "kernel.split_lock_mitigate" = mkDefault 0;

        # > This is required due to some games being unable to reuse their TCP ports
        # > if they're killed and restarted quickly - the default timeout is too large.
        #  - https://github.com/Jovian-Experiments/steamos-customizations-jupiter/commit/4c7b67cc5553ef6c15d2540a08a737019fc3cdf1
        "net.ipv4.tcp_fin_timeout" = mkDefault 5;
        
        # > USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
        # > see comment in include/linux/mm.h in the kernel tree.
        #  - https://github.com/Jovian-Experiments/steamos-customizations-jupiter/commit/e21954bb4743635a9c53016def5158469fa6d7a8
        "vm.max_map_count" = mkJovianDefault 2147483642;
      };
    })
  ];
}
