{
  rustPlatform,
  fetchFromGitHub,
  substituteAll,
  jupiter-hw-support,
  jovian-stubs,
  steamos-polkit-helpers,
  steamdeck-firmware,
  jupiter-dock-updater-bin,
}:
rustPlatform.buildRustPackage rec {
  pname = "steamos-manager";
  version = "24.5.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "steamos-manager";
    rev = "v${version}";
    hash = "sha256-AU3yws5ENrA4flknfbJXp/t9RtkZOaCmrAZ4Bc4uvro=";
  };

  cargoHash = "sha256-HHzQP12/t86OBR1X0JlhmlWDPcBcvjYykh8VPXni9YQ=";

  # tests assume Steam Deck hardware
  doCheck = false;

  patches = [ 
    (substituteAll {
      src = ./hardcode-paths.patch;
      hwsupport = jupiter-hw-support;
      stubs = jovian-stubs;
      polkitHelpers = steamos-polkit-helpers;
      steamDeckFirmware = steamdeck-firmware;
      jupiterDockUpdaterBin = jupiter-dock-updater-bin;
    })
    # FIXME: build steamos-log-submitter and reenable this maybe?
    ./disable-ftrace.patch
  ];

  postInstall = ''
    substituteInPlace data/*/*.service --replace-fail "/usr/lib" "$out/bin"

    install -d -m0755 "$out/share/dbus-1/services/"
    install -d -m0755 "$out/share/dbus-1/system-services/"
    install -d -m0755 "$out/share/dbus-1/system.d/"
    install -d -m0755 "$out/lib/systemd/system/"
    install -d -m0755 "$out/lib/systemd/user/"

    install -m644 "data/system/com.steampowered.SteamOSManager1.service" "$out/share/dbus-1/system-services/"
    install -m644 "data/system/com.steampowered.SteamOSManager1.conf" "$out/share/dbus-1/system.d/"
    install -m644 "data/system/steamos-manager.service" "$out/lib/systemd/system/"

    install -m644 "data/user/com.steampowered.SteamOSManager1.service" "$out/share/dbus-1/services/"
    install -m644 "data/user/steamos-manager.service" "$out/lib/systemd/user/"
  '';
}