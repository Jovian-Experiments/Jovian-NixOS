# Steam Deck-specific configurations
#
# jovian.devices.steamdeck

{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
    ;
  cfg = config.jovian.devices.steamdeck;
in
{
  imports = [
    ./firmware.nix
    ./hw-support.nix
    ./sdgyrodsu.nix
    ./workarounds.nix
  ];

  options = {
    jovian.devices.steamdeck = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Steam Deck-specific configurations.
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

      # it currently causes black/white flashes when showing/hiding planes
      # https://github.com/Jovian-Experiments/jupiter-hw-support/commit/1a2776307a58d065c619d4d7350be6d5a202e991
      # Holo: amdgpu.dcdebugmask=0x40000 bit is set to disable the custom backlight
      # brightness curve support. Needed in order to
      # 1. Fix bug causing only 97% of brightness to be usable
      # 2. Allow the kernel to move closer to upstream
      # 3. Not break userspace currently expecting linear mapping
      # See
      # https://gitlab.steamos.cloud/holo-team/tasks/-/work_items/2237#note_358276
      "amdgpu.dcdebugmask=0x60000"
    ];
    
    # udev rules required for integrated controller to work
    hardware.steam-hardware.enable = true;
  };
}
