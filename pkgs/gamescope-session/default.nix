{
  lib,
  stdenv,
  resholve,
  writeText,
  fetchFromGitHub,
  python3,
  steamdeck-hw-theme,
  steam,
  steam-unwrapped,
  bash,
  coreutils,
  dbus,
  findutils,
  galileo-mura,
  gamescope,
  gnugrep,
  gnused,
  gnutar,
  ibus,
  kdePackages,
  mangohud,
  procps,
  steam_notif_daemon,
  systemd,
  util-linux,
  xbindkeys,
}:

let
  gamescope-session-solution = {
    scripts = [ "lib/steamos/gamescope-session" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      findutils
      gnugrep
      gnused
      kdePackages.kconfig
      procps
      systemd
      util-linux
    ];
    execer = [
      "cannot:${kdePackages.kconfig}/bin/kwriteconfig6"
      "cannot:${util-linux}/bin/flock"
      "cannot:${systemd}/bin/systemd-notify"
    ];
    fake = {
      # use the wrapper
      external = [ "gamescope" ];
      source = [ "/etc/xdg/gamescope-session/environment" ];
    };
    keep = {
      "source:/etc/xdg/gamescope-session/environment" = true;
    };

    prologue = "${writeText "gamescope-session-prologue" ''
      # Don't resholve gamescope so we can use the cap_sys_nice wrapper when available
      # mangohud is not picked up by resholve due to loop_background
      export PATH=/run/wrappers/bin:${gamescope}/bin:$PATH
  
      # Make gamescope discover the Steam cursor theme
      export XCURSOR_PATH=${kdePackages.breeze}/share/icons:${steamdeck-hw-theme}/share/icons

      [ -e /etc/jovian/gamescope-session/pre-start ] && . /etc/jovian/gamescope-session/pre-start
    ''}";
  };

  start-gamescope-session-solution = {
    scripts = [ "bin/start-gamescope-session" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      dbus
      gnugrep
      systemd
      util-linux
    ];
    execer = [
      "cannot:${systemd}/bin/systemctl"
    ];

    # Import user PATH into the environment to be able to start third party tools
    prologue = "${writeText "start-gamescope-session-prologue" ''
      ${systemd}/bin/systemctl --user import-environment PATH
    ''}";
  };

  steam-launcher-solution = {
    scripts = [ "lib/steamos/steam-launcher" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      steam
    ];
    execer = [
      "cannot:${steam}/bin/steam"
    ];
  };

  steam-short-session-tracker-solution = {
    scripts = [ "lib/steamos/steam-short-session-tracker" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      gnutar
    ];
  };
in stdenv.mkDerivation(finalAttrs: {
  pname = "gamescope-session";
  version = "3.16.2-6";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "PKGBUILDs-mirror";
    rev = "jupiter-main/gamescope-${finalAttrs.version}";
    hash = "sha256-iqTIR8WFXMDZPZhvzmiI4c608Q8Kc99hgS5o72KvJmk=";
  };

  patches = [
    ./0001-gamescope-session-Add-xdg-environment-overrides.patch
    ./0002-start-gamescope-session-do-not-set-XDG_DESKTOP_PORTA.patch
  ];

  postPatch = ''
    patchShebangs .

    substituteInPlace gamescope-session --replace-fail /usr/share ${steamdeck-hw-theme}/share
    substituteInPlace steam-short-session-tracker --replace-fail /usr/lib/steam ${steam-unwrapped}/lib/steam

    substituteInPlace galileo-mura-setup.service --replace-fail /usr/bin ${galileo-mura}/bin
    substituteInPlace gamescope-mangoapp.service --replace-fail /usr/bin ${mangohud}/bin
    substituteInPlace gamescope-session.service --replace-fail /usr/lib $out/lib
    # Jovian: we're not going to install this
    # substituteInPlace gamescope-xbindkeys.service --replace-fail /usr/bin ${xbindkeys}/bin
    substituteInPlace ibus-gamescope.service --replace-fail /usr/bin ${ibus}/bin

    # can't resholve systemd units :(
    substituteInPlace steam-launcher.service \
      --replace-fail /usr/lib $out/lib \
      --replace-fail /bin/bash ${lib.getExe bash} \
      --replace-fail kill ${lib.getExe' util-linux "kill"} \
      --replace-fail pgrep ${lib.getExe' procps "pgrep"}

    substituteInPlace steam-short-session-tracker.service --replace-fail /usr/lib $out/lib
    substituteInPlace steam-notif-daemon.service --replace-fail /usr/bin ${steam_notif_daemon}/bin
  '';

  nativeBuildInputs = [python3];

  # Largely copied from upstream
  installPhase = ''
    runHook preInstall
    install -D -m 755 gamescope-session $out/lib/steamos/gamescope-session
    install -D -m 755 steam-launcher $out/lib/steamos/steam-launcher
    install -D -m 755 steam-short-session-tracker $out/lib/steamos/steam-short-session-tracker

    install -D -m 755 start-gamescope-session $out/bin/start-gamescope-session
    install -D -m 644 gamescope-wayland.desktop $out/share/wayland-sessions/gamescope-wayland.desktop

    # url handling
    install -D -m 644 steam_http_loader.desktop $out/share/applications/steam_http_loader.desktop
    install -D -m 644 gamescope-mimeapps.list $out/share/applications/gamescope-mimeapps.list
    install -D -m 755 steam-http-loader $out/bin/steam-http-loader

    # systemd
    install -D -m 644 galileo-mura-setup.service $out/lib/systemd/user/galileo-mura-setup.service
    install -D -m 644 gamescope-session.service $out/lib/systemd/user/gamescope-session.service
    install -D -m 644 gamescope-session.target $out/lib/systemd/user/gamescope-session.target
    install -D -m 644 gamescope-mangoapp.service $out/lib/systemd/user/gamescope-mangoapp.service
    install -D -m 644 ibus-gamescope.service  $out/lib/systemd/user/ibus-gamescope.service 
    install -D -m 644 steam-launcher.service $out/lib/systemd/user/steam-launcher.service
    install -D -m 644 steam-short-session-tracker.service $out/lib/systemd/user/steam-short-session-tracker.service
    install -D -m 644 steam-notif-daemon.service $out/lib/systemd/user/steam-notif-daemon.service
    # Jovian: don't install this, it's not useful for us
    # install -D -m 644 gamescope-xbindkeys.service $out/lib/systemd/user/gamescope-xbindkeys.service

    # portals
    install -D -m 644 gamescope-portals.conf $out/share/xdg-desktop-portal/gamescope-portals.conf

    ${resholve.phraseSolution "gamescope-session" gamescope-session-solution}
    ${resholve.phraseSolution "start-gamescope-session" start-gamescope-session-solution}
    ${resholve.phraseSolution "steam-launcher" steam-launcher-solution}
    ${resholve.phraseSolution "steam-short-session-tracker" steam-short-session-tracker-solution}

    runHook postInstall
  '';

  passthru.providedSessions = ["gamescope-wayland"];
})
