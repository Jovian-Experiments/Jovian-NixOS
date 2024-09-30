final: super:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
in
rec {
  linux-firmware-jupiter = final.callPackage ./pkgs/linux-firmware {
    linux-firmware = super.linux-firmware;
  };
  linuxPackages_jovian = linuxPackagesFor final.linux_jovian;
  linux_jovian = final.callPackage ./pkgs/linux-jovian {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export-rt-sched-migrate
    ];
  };

  galileo-mura = final.callPackage ./pkgs/galileo-mura { };

  gamescope = import ./pkgs/gamescope {
    gamescope' = super.gamescope;
    inherit (final) fetchFromGitHub;
  };
  gamescope-wsi = gamescope.override {
    enableExecutable = false;
    enableWsi = true;
  };
  gamescope-session = final.callPackage ./pkgs/gamescope-session { };

  mesa-radeonsi-jupiter = final.callPackage ./pkgs/mesa-radeonsi-jupiter {};
  mesa-radv-jupiter = final.callPackage ./pkgs/mesa-radv-jupiter {};

  jupiter-fan-control = final.callPackage ./pkgs/jupiter-fan-control { };
  powerbuttond = final.callPackage ./pkgs/powerbuttond { };
  steam_notif_daemon = final.callPackage ./pkgs/steam_notif_daemon { };
  wakehook = final.callPackage ./pkgs/wakehook { };

  jupiter-hw-support = final.callPackage ./pkgs/jupiter-hw-support { };
  steamdeck-hw-theme = final.callPackage ./pkgs/jupiter-hw-support/theme.nix { };
  steamdeck-firmware = final.callPackage ./pkgs/jupiter-hw-support/firmware.nix { };
  steamdeck-bios-fwupd = final.callPackage ./pkgs/jupiter-hw-support/bios-fwupd.nix { };
  jupiter-dock-updater-bin = final.callPackage ./pkgs/jupiter-dock-updater-bin { };
  steamos-manager = final.callPackage ./pkgs/steamos-manager { };
  steamos-polkit-helpers = final.callPackage ./pkgs/jupiter-hw-support/polkit-helpers.nix { };
  steamdeck-dsp = final.callPackage ./pkgs/steamdeck-dsp { };

  opensd = final.callPackage ./pkgs/opensd { };

  jovian-stubs = final.callPackage ./pkgs/jovian-stubs { };
  jovian-greeter = final.callPackage ./pkgs/jovian-greeter { };
  jovian-steam-protocol-handler = final.callPackage ./pkgs/jovian-steam-protocol-handler { };
  jovian-support-scripts = final.callPackage ./pkgs/jovian-support-scripts { };

  jovian-documentation = final.callPackage ./support/docs {
    pagefind = final.callPackage ./pkgs/pagefind { };
    documentationPath = final.callPackage (
      { runCommand
      }:
      runCommand "jovian-documentation-source" {
        src = ./docs;
      } ''
        (PS4=" $ "; set -x
        cp --no-preserve=mode -r $src src
        chmod -R +w src
        rm -vf src/README.md
        cp -v ${./CONTRIBUTING.md} src/contributing.md
        printf '# Home\n\n' | cat - ${./README.md} > src/index.md
        cp -v ${./support/docs/search.md} src/search.md
        mv src $out
        )
      ''
    ) { };
  };

  jovian-hardware-survey = final.callPackage ./pkgs/jovian-hardware-survey { };

  steamPackages = super.steamPackages.overrideScope (_: scopeSuper: {
    steam = final.callPackage ./pkgs/steam-jupiter/unwrapped.nix {
      steam-original = scopeSuper.steam;
    };
    steam-fhsenv = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
      steam-fhsenv = scopeSuper.steam-fhsenv;
    };
    steam-fhsenv-small = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
      steam-fhsenv = scopeSuper.steam-fhsenv-small;
    };
  });

  sdgyrodsu = final.callPackage ./pkgs/sdgyrodsu { };

  decky-loader = final.callPackage ./pkgs/decky-loader { };
  decky-loader-prerelease = decky-loader;
}
