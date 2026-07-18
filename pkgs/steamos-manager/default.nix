{
  rustPlatform,
  fetchFromGitLab,
  replaceVars,
  jupiter-hw-support,
  jovian-stubs,
  steamdeck-firmware,
  jupiter-dock-updater-bin,
  coreutils,
  iwd,
  trace-cmd,
  iw,
  dmidecode,
  pkg-config,
  wrapGAppsNoGuiHook,
  glib,
  gsettings-desktop-schemas,
  speechd-minimal,
  udev,
  scx,
}:
rustPlatform.buildRustPackage rec {
  pname = "steamos-manager";
  version = "26.4.0";

  src = fetchFromGitLab {
    domain = "gitlab.steamos.cloud";
    owner = "holo";
    repo = "steamos-manager";
    tag = "v${version}";
    hash = "sha256-rtLLs/4Ip5UxawyGC18s/1Z8N2qrgrlgyG0rXEWlTiE=";
  };

  cargoHash = "sha256-ktqic3Okx5K6JvWRrFZphitCGRNrtRCQBeMGFiV812k=";

  # tests assume Steam Deck hardware and FHS paths
  doCheck = false;

  patches = [ 
    (replaceVars ./hardcode-paths.patch
    {
      stubs = jovian-stubs;
      steamDeckFirmware = steamdeck-firmware;
      jupiterDockUpdaterBin = jupiter-dock-updater-bin;
      hwsupport = jupiter-hw-support;
      coreutils = coreutils;
      iwd = iwd;
      traceCmd = trace-cmd;
      iw = iw;
      dmidecode = dmidecode;
      scx = scx.rustscheds;
      out = null;
    })
    ./fix-sddm-config-path.patch
    # FIXME: build steamos-log-submitter and reenable this maybe?
    ./disable-ftrace.patch
  ];

  postPatch = ''
    substituteInPlace \
      steamos-manager/src/daemon/{root,user}.rs \
      steamos-manager/src/hardware.rs \
      steamos-manager/src/platform.rs \
      data/*/*.service \
      --replace-warn "@out@" "$out"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    glib
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    speechd-minimal
    udev
  ];

  postInstall = ''
    # fixup location to match vendor packaging
    mkdir $out/lib
    mv $out/bin/steamos-manager $out/lib/steamos-manager

    # copied from vendor makefile, s@$(DESTDIR)/usr@$out@g
    install -d -m0755 "$out/share/dbus-1/services/"
    install -d -m0755 "$out/share/dbus-1/system-services/"
    install -d -m0755 "$out/share/dbus-1/system.d/"
    install -d -m0755 "$out/lib/systemd/system/"
    install -d -m0755 "$out/lib/systemd/user/"

    install -D -m644 -t "$out/share/steamos-manager/devices" "data/devices/"*
    install -D -m644 LICENSE "$out/share/licenses/steamos-manager/LICENSE"

    install -m644 "data/platform.toml" "$out/share/steamos-manager/"

    install -m644 "data/system/com.steampowered.SteamOSManager1.service" "$out/share/dbus-1/system-services/"
    install -m644 "data/system/com.steampowered.SteamOSManager1.conf" "$out/share/dbus-1/system.d/"
    install -m644 "data/system/steamos-manager.service" "$out/lib/systemd/system/"

    install -m644 "data/user/com.steampowered.SteamOSManager1.service" "$out/share/dbus-1/services/"
    install -m644 "data/user/steamos-manager.service" "$out/lib/systemd/user/"
    install -m644 "data/user/steamos-manager-session-cleanup.service" "$out/lib/systemd/user/"
    install -m644 "data/user/steamos-manager-configure-cecd.service" "$out/lib/systemd/user/"
  '';

  postFixup = ''
    wrapGApp $out/lib/steamos-manager
  '';
}
