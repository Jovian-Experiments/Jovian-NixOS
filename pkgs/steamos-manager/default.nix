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
  pipewire,
  wireplumber-jupiter,
  dmidecode,
  pkg-config,
  wrapGAppsNoGuiHook,
  glib,
  gsettings-desktop-schemas,
  speechd-minimal,
  udev,
}:
rustPlatform.buildRustPackage rec {
  pname = "steamos-manager";
  version = "26.0.1-unstable-2026-04-02";

  src = fetchFromGitLab {
    domain = "gitlab.steamos.cloud";
    owner = "holo";
    repo = "steamos-manager";
    rev = "ebd78b881ec4c04585bb4e9928ac77770d0dd059";
    hash = "sha256-9aKl8YV6Im8dShkMSPeoikTdcTxoTdJX9S1ZDZ4uAcQ=";
  };

  cargoHash = "sha256-45X3ixQ200LVfSDhMcBzqjQsebydw76nGeqn7c7/rDY=";

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
      pipewire = pipewire;
      wireplumber = wireplumber-jupiter;
      dmidecode = dmidecode;
      out = null;
    })
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