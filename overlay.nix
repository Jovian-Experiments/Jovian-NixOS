final: prev: {
  jovianPackages = final.lib.makeScope final.newScope (self: {
    # vendor kernel/firmware
    linux = self.callPackage ./pkgs/linux {
      kernelPatches = [
        final.kernelPatches.bridge_stp_helper
        final.kernelPatches.request_key_helper
      ];
    };
    linuxPackages = final.linuxPackagesFor self.linux;
    linux-firmware-holo = self.callPackage ./pkgs/linux-firmware-holo { };

    # vendor Mesa branch
    mesa-radeonsi = self.callPackage ./pkgs/mesa-radeonsi { };
    mesa-radv = self.callPackage ./pkgs/mesa-radv { };

    # Steam Deck hardware support
    jupiter-fan-control = self.callPackage ./pkgs/jupiter-fan-control { };
    galileo-mura = self.callPackage ./pkgs/galileo-mura { };
    jupiter-hw-support = self.callPackage ./pkgs/jupiter-hw-support { };
    steamdeck-firmware = self.callPackage ./pkgs/jupiter-hw-support/firmware.nix { };
    steamdeck-bios-fwupd = self.callPackage ./pkgs/jupiter-hw-support/bios-fwupd.nix { };
    jupiter-dock-updater-bin = self.callPackage ./pkgs/jupiter-dock-updater-bin { };

    # Steam Machine CEC bits
    cecd = self.callPackage ./pkgs/cecd { };
    inputattach-cec-units = self.callPackage ./pkgs/inputattach-cec-units { };

    # Deck/Machine custom DSP config
    steamdeck-dsp = self.callPackage ./pkgs/steamdeck-dsp { };
    noisetorch-ladspa = self.callPackage ./pkgs/noisetorch-ladspa { };
    # requires vendor patches to work
    pipewire = self.callPackage ./pkgs/pipewire {
      pipewire' = prev.pipewire;
    };
    wireplumber = self.callPackage ./pkgs/wireplumber {
      wireplumber' = prev.wireplumber;
    };

    # Steam session parts
    gamescope = import ./pkgs/gamescope {
      gamescope' = prev.gamescope;
      inherit (final) fetchFromGitHub;
    };
    gamescope-wsi = self.gamescope.override {
      enableExecutable = false;
      enableWsi = true;
    };

    mangohud = import ./pkgs/mangohud {
      mangohud' = prev.mangohud;
      inherit (final) fetchpatch;
    };

    gamescope-session = self.callPackage ./pkgs/gamescope-session { };

    # Steam session app integration
    xdg-desktop-portal-gamescope = self.callPackage ./pkgs/xdg-desktop-portal-gamescope { };
    xdg-desktop-portal-holo = self.callPackage ./pkgs/xdg-desktop-portal-holo { };
    steam_notif_daemon = self.callPackage ./pkgs/steam_notif_daemon { };

    # Steam session OS controls glue
    steamos-manager = self.callPackage ./pkgs/steamos-manager { };
    vpower = self.callPackage ./pkgs/vpower { };

    # Steam session input device glue
    powerbuttond = self.callPackage ./pkgs/powerbuttond { };
    inputplumber = self.callPackage ./pkgs/inputplumber {
      inputplumber' = prev.inputplumber;
    };

    # despite being in jupiter-hw-support, these are actually generic
    steamdeck-hw-theme = self.callPackage ./pkgs/jupiter-hw-support/theme.nix { };
    holo-polkit-helpers = self.callPackage ./pkgs/jupiter-hw-support/polkit-helpers.nix { };

    # session switching glue
    holo-session-selection = self.callPackage ./pkgs/holo-session-selection/default.nix { };

    # stubs for the Steam session in fhsenv
    jovian-stubs = self.callPackage ./pkgs/jovian-stubs { };
    jovian-steam-protocol-handler = self.callPackage ./pkgs/jovian-steam-protocol-handler { };

    steam-unwrapped = self.callPackage ./pkgs/steam/unwrapped.nix {
      steam-unwrapped' = prev.steam-unwrapped;
    };
    steam = self.callPackage ./pkgs/steam/fhsenv.nix {
      steam' = prev.steam;
    };
    steam-run = self.steam.run;

    # desktop VRAM optimizations
    dmemcg-booster = self.callPackage ./pkgs/dmemcg-booster { };
    kcgroups = self.callPackage ./pkgs/kcgroups { };
    plasma-foreground-booster = self.callPackage ./pkgs/plasma-foreground-booster { };

    # misc third party stuff
    sdgyrodsu = self.callPackage ./pkgs/sdgyrodsu { };

    decky-loader = self.callPackage ./pkgs/decky-loader/stable.nix { };
    decky-loader-prerelease = self.callPackage ./pkgs/decky-loader/prerelease.nix { };

    # Jovian internal-ish tooling
    jovian-hardware-survey = self.callPackage ./pkgs/jovian-hardware-survey { };
    jovian-updater-logo-helper = self.callPackage ./pkgs/jovian-updater-logo-helper { };
    docs = self.callPackage ./support/docs {
      documentationPath = self.callPackage (
        {
          runCommand,
        }:
        runCommand "jovian-documentation-source"
          {
            src = ./docs;
          }
          ''
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
  });
}
