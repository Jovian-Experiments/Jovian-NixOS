{ lib
, stdenv
, callPackage
, resholve
, bash
, coreutils
, e2fsprogs
, exfatprogs
, f3
, findutils
, gawk
, gnugrep
, gnused
, jq
, parted
, procps
, systemd
, util-linux
}:

let
  src = callPackage ./src.nix { };

  solution = {
    scripts = [ "bin/*" "lib/hwsupport/*.sh" "lib/hwsupport/common-functions" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      e2fsprogs
      exfatprogs
      f3
      findutils
      gawk
      gnugrep
      gnused
      jq
      parted
      procps
      systemd
      util-linux

      "${placeholder "out"}/lib/hwsupport"
    ];
    execer = [
      "cannot:${e2fsprogs}/bin/fsck.ext4"
      "cannot:${e2fsprogs}/bin/mkfs.ext4"
      "cannot:${procps}/bin/pgrep"
      "cannot:${systemd}/bin/systemctl"
      "cannot:${systemd}/bin/udevadm"
      "cannot:${util-linux}/bin/flock"
      "cannot:${util-linux}/bin/setpriv"

      "cannot:${placeholder "out"}/lib/hwsupport/format-device.sh"
      "cannot:${placeholder "out"}/lib/hwsupport/steamos-automount.sh"
    ];
    fake = {
      # we're using wrappers for these
      external = [ "umount" ];
    };
    fix = {
      "/usr/lib/hwsupport/format-device.sh" = true;
      "/usr/lib/hwsupport/steamos-automount.sh" = true;
    };
    keep = {
      # pre-applied via patch
      # FIXME: why do we need to discard string context here?
      "${builtins.unsafeDiscardStringContext "${systemd}/bin/systemd-run"}" = true;
      "source:${placeholder "out"}/lib/hwsupport/common-functions" = true;
    };
  };
in
stdenv.mkDerivation {
  pname = "jupiter-hw-support";

  inherit src;
  inherit (src) version;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp usr/bin/jupiter-check-support $out/bin

    mkdir -p $out/lib
    cp -r usr/lib/hwsupport $out/lib

    substituteInPlace $out/lib/hwsupport/* \
      --replace-warn ". /usr/lib/hwsupport" ". $out/lib/hwsupport"

    mkdir -p $out/lib/udev/rules.d
    cp usr/lib/udev/rules.d/99-steamos-automount.rules $out/lib/udev/rules.d
    cp usr/lib/udev/rules.d/99-sdcard-rescan.rules $out/lib/udev/rules.d

    substituteInPlace $out/lib/udev/rules.d/*.rules \
      --replace-fail "/bin/systemd-run" "${systemd}/bin/systemd-run" \
      --replace-fail "/usr/lib/hwsupport" "$out/lib/hwsupport"

    ${resholve.phraseSolution "jupiter-hw-support" solution}

    runHook postInstall
  '';

  meta = with lib; {
    description = ''
      Steam Deck (Jupiter) hardware support package

      This package only contains the utility scripts as well as UCM files.
      For the themes as well as unfree firmware, see the `steamdeck-theme`
      and `steamdeck-firmware` packages.
    '';
    license = licenses.mit;
  };
}
