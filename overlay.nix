#
# █▀▀▀▀▀▀▀▀▀▀▀█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
# █  WARNING  █  This overlay.nix file is not a public interface.  █
# █▄▄▄▄▄▄▄▄▄▄▄█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
#
# Importing this overlay in your NixOS configuration may cause unexpected
# errors. Import the Jovian NixOS modules in your NixOS configuration,
# which will import this overlay correctly.
# 
final: prev:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
in

if prev ? linux_jovian && !( prev.__jovian_ignore_guard or false ) then builtins.throw ''
  ${""  }The Jovian NixOS overlay was already previously imported in this
         NixOS configuration. This is unsupported, and may cause build failures.

         Please make sure that you are not adding the Jovian NixOS overlay
         to `nixpkgs.overlays` in your NixOS configuration.

         Adding the overlay is not needed when importing the Jovian NixOS
         module in your configuration.

         If you are not using the Jovian NixOS modules, make sure the
         overlay is not being imported twice.

         The overlay is not part of the public interface, and care should
         be taken when using it directly.

         * * *
         Technical detail:
         This is checking for `linux_jovian` being already set. If another
         module or overlay is adding `linux_jovian` to the package set, it
         may also trigger this error.
         * * *
'' else

let
  # The different parts of this tooling need to "peek" into the overlay.
  # (Mainly to read the overlaid package metadata.)
  pkgs'WithoutGuardClause =
    final.appendOverlays [(_: _: {
      __jovian_ignore_guard = true;
    })]
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
  holo-session-selection = final.callPackage ./pkgs/holo-session-selection/default.nix { };
  steamdeck-dsp = final.callPackage ./pkgs/steamdeck-dsp { };
  pipewire-jupiter = final.callPackage ./pkgs/pipewire {
    pipewire' = prev.pipewire;
  };
  wireplumber-jupiter = final.callPackage ./pkgs/wireplumber {
    wireplumber' = prev.wireplumber;
  };

  opensd = final.callPackage ./pkgs/opensd { };

  jovian-stubs = final.callPackage ./pkgs/jovian-stubs { };
  jovian-steam-protocol-handler = final.callPackage ./pkgs/jovian-steam-protocol-handler { };
  jovian-updater-logo-helper = final.callPackage ./pkgs/jovian-updater-logo-helper { };

  jovian-documentation = pkgs'WithoutGuardClause.callPackage ./support/docs {
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
