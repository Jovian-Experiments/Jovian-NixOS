# Steam Machine-specific configurations
#
# jovian.devices.steammachine

{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
    ;
  cfg = config.jovian.devices.steammachine;
in
{
  imports = [
    ./firmware.nix
    ./lightbar.nix
  ];

  options = {
    jovian.devices.steammachine = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Steam Machine-specific configurations.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    jovian.hardware = {
      has.amd.gpu = true;
      valve.enable = true;
    };

    boot.kernelParams = [
      # Valve says:
      # amdgpu.sched_hw_submission is set to 4 to avoid bubbles of lack-of work
      # with the default (2).
      # 4 is the maximum that is supported across RDNA2 + RDNA3.
      # Any more results in a hang at startup on RDNA3.
      "amdgpu.sched_hw_submission=4"
    ];
  };
}
