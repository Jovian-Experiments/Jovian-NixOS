{
  stdenv,
  callPackage,
  resholve,
  bash,
  coreutils,
  dmidecode,
  gawk,
  gnugrep,
  jovian-stubs,
  jupiter-dock-updater-bin,
  jupiter-hw-support,
  steamdeck-firmware,
  systemd,
  wirelesstools,
}:

let
  src = callPackage ./src.nix { };

  solution = {      
    scripts = [ "bin/steamos-polkit-helpers/*" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      dmidecode
      gawk
      gnugrep
      "${jupiter-dock-updater-bin}/lib/jupiter-dock-updater"
      jovian-stubs
      jupiter-hw-support
      "${jupiter-hw-support}/lib/hwsupport"
      steamdeck-firmware
      systemd
      wirelesstools
    ];
    execer = [
      "cannot:${jovian-stubs}/bin/jupiter-biosupdate"
      "cannot:${jovian-stubs}/bin/steamos-reboot"
      "cannot:${jovian-stubs}/bin/steamos-factory-reset-config"
      "cannot:${jovian-stubs}/bin/steamos-select-branch"
      "cannot:${jovian-stubs}/bin/steamos-update"
      "cannot:${jupiter-dock-updater-bin}/lib/jupiter-dock-updater/jupiter-dock-updater.sh"
      "cannot:${jupiter-hw-support}/bin/jupiter-check-support"
      "cannot:${jupiter-hw-support}/lib/hwsupport/format-device.sh"
      "cannot:${jupiter-hw-support}/lib/hwsupport/format-sdcard.sh"
      "cannot:${jupiter-hw-support}/lib/hwsupport/trim-devices.sh"
      "cannot:${steamdeck-firmware}/bin/jupiter-biosupdate"
      "cannot:${systemd}/bin/poweroff"
      "cannot:${systemd}/bin/reboot"
      "cannot:${systemd}/bin/systemctl"
      "cannot:${systemd}/bin/systemd-cat"
    ];
    fake = {
      external = ["pkexec"];
    };
    fix = {
      "/usr/bin/jupiter-biosupdate" = true;
      "/usr/bin/jupiter-check-support" = true;
      "/usr/bin/steamos-factory-reset-config" = true;
      "/usr/bin/steamos-reboot" = true;
      "/usr/bin/steamos-select-branch" = true;
      "/usr/bin/steamos-update" = true;
      "/usr/lib/hwsupport/format-device.sh" = true;
      "/usr/lib/hwsupport/format-sdcard.sh" = true;
      "/usr/lib/hwsupport/trim-devices.sh" = true;
      "/usr/lib/jupiter-dock-updater/jupiter-dock-updater.sh" = true;
    };
    keep = {
      # this file is removed in latest versions of hwsupport
      "/usr/lib/hwsupport/jupiter-amp-control" = true;
    };
  };
in stdenv.mkDerivation {
  pname = "steamos-polkit-helpers";

  inherit src;
  inherit (src) version;

  patchPhase = ''
    runHook prePatch
  
    substituteInPlace usr/share/polkit-1/actions/org.valve.steamos.policy --replace-fail /usr $out

    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    cp -r usr/bin/steamos-polkit-helpers $out/bin/steamos-polkit-helpers
    cp -r usr/share/polkit-1 $out/share

    ${resholve.phraseSolution "steamos-polkit-helpers" solution}
    runHook postInstall
  '';
}
