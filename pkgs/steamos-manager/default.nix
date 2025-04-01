{
  rustPlatform,
  fetchFromGitHub,
  replaceVars,
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
  version = "25.3.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "steamos-manager";
    rev = "v${version}";
    hash = "sha256-oclgieBcEPknkhHJduSzvcSx1PvUA5YtFZOy3I39waE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-sxM6UHZPN/bu/Rgoc62hzem7POGyb8iE9CHDDU23gMs=";

  # tests assume Steam Deck hardware and FHS paths
  doCheck = false;

  patches = [ 
    (replaceVars ./hardcode-paths.patch
    {
      stubs = jovian-stubs;
      steamDeckFirmware = steamdeck-firmware;
      jupiterDockUpdaterBin = jupiter-dock-updater-bin;
      hwsupport = jupiter-hw-support;
      polkitHelpers = steamos-polkit-helpers;
      iwd = iwd;
      traceCmd = trace-cmd;
      iw = iw;
      out = null;
    })
    # FIXME: build steamos-log-submitter and reenable this maybe?
    ./disable-ftrace.patch
  ];

  postPatch = ''
    substituteInPlace \
      src/daemon/{root,user}.rs \
      src/platform.rs \
      data/*/*.service \
      --replace-fail "@out@" "$out"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  postInstall = ''
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