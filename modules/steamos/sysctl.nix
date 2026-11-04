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
        # From holo-config-kernel
        # https://github.com/Jovian-Experiments/PKGBUILDs-mirror/tree/holo-main/holo-config-kernel

        # This is required to avoid some connectivity failures in ICMP-blocking scenarios
        # See https://github.com/ValveSoftware/SteamOS/issues/1006
        "net.ipv4.tcp_mtu_probing" = mkDefault 1;

        # This is required due to some games being unable to reuse their TCP ports
        # if they're killed and restarted quickly - the default timeout is too large.
        "net.ipv4.tcp_fin_timeout" = mkDefault 5;

        # There are some CFS settings that seems to improve the gaming experience;
        # most of these tunings are considered debugfs material [0], so we can't
        # rely on sysctl settings. There is one tuning that is a sysctl though.
        #
        # JOVIAN: said service tries to tweak settings that no longer exist on latest kernels.
        # The settings that do still exist are in the following tmpfiles rules.
        "kernel.sched_cfs_bandwidth_slice_u" = mkDefault 3000;

        # Prevents intentional slowdowns in case games experience split locks
        # This is valid for kernels v6.0+
        "kernel.split_lock_mitigate" = mkDefault 0;

        # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
        # see comment in include/linux/mm.h in the kernel tree.
        "vm.max_map_count" = mkJovianDefault 2147483642;
      };

      systemd.tmpfiles.settings."99-jovian" = {
        "/sys/kernel/debug/sched/migration_cost_ns".w.argument = "50000";
        "/sys/kernel/debug/sched/nr_migrate".w.argument = "128";
      };
    })
  ];
}
