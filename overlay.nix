final: super:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
in
{
  acp5x-ucm = final.callPackage ./pkgs/acp5x-ucm { };
  linux-firmware = final.callPackage ./pkgs/linux-firmware {
    linux-firmware = super.linux-firmware;
  };
  linuxPackages_jovian = linuxPackagesFor final.linux_jovian;
  linux_jovian = super.callPackage ./pkgs/linux-jovian {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export-rt-sched-migrate
    ];
  };
  gamescope = super.callPackage ./pkgs/gamescope {
    udev = final.systemdMinimal;
  };
  jovian-controller = super.callPackage ./pkgs/jovian-controller { };
  jupiter-fan-control = final.callPackage ./pkgs/jupiter-fan-control { };
}
