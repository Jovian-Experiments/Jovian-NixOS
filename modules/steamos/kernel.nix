{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.jovian.steamos.enableVendorKernel = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = ''
      Enable SteamOS kernel branch.

      These are only validated on a small subset of hardware, which is mostly handhelds,
      so enabling this on desktop systems is not recommended.
    '';
  };

  config = lib.mkIf (config.jovian.steamos.enableVendorKernel) {
    boot.kernelPackages = lib.mkDefault pkgs.jovianPackages.linuxPackages;

    # see https://github.com/Jovian-Experiments/steamos-customizations-jupiter/blob/jupiter-20241107.1/misc/modules-load.d/hid-preload.conf
    boot.kernelModules = [
      "hid_nintendo"
      "hid_playstation"
    ];

    # Ensures modules missing from the vendor kernel don't cause a generation build failure.
    jovian.workarounds.ignoreMissingKernelModules = lib.mkDefault true;
  };
}
