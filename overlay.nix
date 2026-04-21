final: prev:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
in
rec {
  linux-firmware-jupiter = final.callPackage ./pkgs/linux-firmware {
    linux-firmware = prev.linux-firmware;
  };
  linuxPackages_jovian = linuxPackagesFor final.linux_jovian;
  linux_jovian = final.callPackage ./pkgs/linux-jovian {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
    ];
  };

  galileo-mura = final.callPackage ./pkgs/galileo-mura { };

  # This can't be callPackage, because it breaks the arguments
  # being passed in to `override`.
  gamescope = import ./pkgs/gamescope {
    gamescope' = prev.gamescope;
    inherit (final) fetchFromGitHub;
  };
  gamescope-wsi = gamescope.override {
    enableExecutable = false;
    enableWsi = true;
  };
  gamescope-session = final.callPackage ./pkgs/gamescope-session { };
  xdg-desktop-portal-gamescope = final.callPackage ./pkgs/xdg-desktop-portal-gamescope { };
  xdg-desktop-portal-holo = final.callPackage ./pkgs/xdg-desktop-portal-holo { };

  inputplumber = final.callPackage ./pkgs/inputplumber {
    inputplumber' = prev.inputplumber;
  };

  mangohud = final.callPackage ./pkgs/mangohud {
    mangohud' = prev.mangohud;
  };

  mesa-radeonsi-jupiter = final.callPackage ./pkgs/mesa-radeonsi-jupiter {};
  mesa-radv-jupiter = final.callPackage ./pkgs/mesa-radv-jupiter {};

  noisetorch-ladspa = final.callPackage ./pkgs/noisetorch-ladspa {};

  jupiter-fan-control = final.callPackage ./pkgs/jupiter-fan-control { };
  powerbuttond = final.callPackage ./pkgs/powerbuttond { };
  steam_notif_daemon = final.callPackage ./pkgs/steam_notif_daemon { };

  jupiter-hw-support = final.callPackage ./pkgs/jupiter-hw-support { };
  steamdeck-hw-theme = final.callPackage ./pkgs/jupiter-hw-support/theme.nix { };
  steamdeck-firmware = final.callPackage ./pkgs/jupiter-hw-support/firmware.nix { };
  steamdeck-bios-fwupd = final.callPackage ./pkgs/jupiter-hw-support/bios-fwupd.nix { };
  jupiter-dock-updater-bin = final.callPackage ./pkgs/jupiter-dock-updater-bin { };
  steamos-manager = final.callPackage ./pkgs/steamos-manager { };
  holo-polkit-helpers = final.callPackage ./pkgs/jupiter-hw-support/polkit-helpers.nix { };
  steamdeck-dsp = final.callPackage ./pkgs/steamdeck-dsp { };
  wireplumber-jupiter = final.callPackage ./pkgs/wireplumber {
    wireplumber' = prev.wireplumber;
  };

  opensd = final.callPackage ./pkgs/opensd { };

  jovian-stubs = final.callPackage ./pkgs/jovian-stubs { };
  jovian-steam-protocol-handler = final.callPackage ./pkgs/jovian-steam-protocol-handler { };
  jovian-updater-logo-helper = final.callPackage ./pkgs/jovian-updater-logo-helper { };

  jovian-documentation = final.callPackage ./support/docs {
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

  steam-unwrapped = final.callPackage ./pkgs/steam-jupiter/unwrapped.nix {
    steam-unwrapped' = prev.steam-unwrapped;
  };
  steam = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
    steam = prev.steam;
  };

  cecd = final.callPackage ./pkgs/cecd { };
  inputattach-cec-units = final.callPackage ./pkgs/inputattach-cec-units { };

  dmemcg-booster = final.callPackage ./pkgs/dmemcg-booster { };
  kcgroups = final.callPackage ./pkgs/kcgroups { };
  plasma-foreground-booster = final.callPackage ./pkgs/plasma-foreground-booster { };

  vpower = final.callPackage ./pkgs/vpower { };

  sdgyrodsu = final.callPackage ./pkgs/sdgyrodsu { };

  decky-loader = final.callPackage ./pkgs/decky-loader { };
  decky-loader-prerelease = final.callPackage ./pkgs/decky-loader/prerelease.nix { };
}
