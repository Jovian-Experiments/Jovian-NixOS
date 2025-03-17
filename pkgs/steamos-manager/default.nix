{
  rustPlatform,
  fetchFromGitHub,
  substituteAll,
  jupiter-hw-support,
  jovian-stubs,
  steamos-polkit-helpers,
  steamdeck-firmware,
  jupiter-dock-updater-bin,
  iwd,
  trace-cmd,
  iw,
  pkg-config,
  udev,
}:
rustPlatform.buildRustPackage rec {
  pname = "steamos-manager";
  version = "25.1.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "steamos-manager";
    rev = "v${version}";
    hash = "sha256-cF5E9dE0lxj4WLT3+L0s8UG/r51ymSP+VGBcY79Y0OQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-pu+tjUcg81voPErYBJA8gwPGLZJebTkYytiJSJi4MVk=";

  # tests assume Steam Deck hardware and FHS paths
  doCheck = false;

  patches = [ 
    (substituteAll {
      src = ./hardcode-paths.patch;
      stubs = jovian-stubs;
      steamDeckFirmware = steamdeck-firmware;
      jupiterDockUpdaterBin = jupiter-dock-updater-bin;
      hwsupport = jupiter-hw-support;
      polkitHelpers = steamos-polkit-helpers;
      iwd = iwd;
      traceCmd = trace-cmd;
      iw = iw;
    })
    # FIXME: build steamos-log-submitter and reenable this maybe?
    ./disable-ftrace.patch
  ];

  postPatch = ''
    substituteInPlace src/daemon/{root,user}.rs src/platform.rs --replace-fail "/usr/share" "$out/share"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  postInstall = ''
    substituteInPlace data/*/*.service --replace-fail "/usr/lib" "$out/bin"

    install -d -m0755 "$out/share/dbus-1/services/"
    install -d -m0755 "$out/share/dbus-1/system-services/"
    install -d -m0755 "$out/share/dbus-1/system.d/"
    install -d -m0755 "$out/lib/systemd/system/"
    install -d -m0755 "$out/lib/systemd/user/"

  	install -D -m644 -t "$out/share/steamos-manager/platforms" "data/platforms/"*

    install -m644 "data/system/com.steampowered.SteamOSManager1.service" "$out/share/dbus-1/system-services/"
    install -m644 "data/system/com.steampowered.SteamOSManager1.conf" "$out/share/dbus-1/system.d/"
    install -m644 "data/system/steamos-manager.service" "$out/lib/systemd/system/"

    install -m644 "data/user/com.steampowered.SteamOSManager1.service" "$out/share/dbus-1/services/"
    install -m644 "data/user/steamos-manager.service" "$out/lib/systemd/user/"
  '';
}