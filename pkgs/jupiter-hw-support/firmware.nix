{ lib
, stdenv
, callPackage
, autoPatchelfHook
, makeWrapper
, python3

# jupiter-biosupdate
, libkrb5
, zlib
, jq
, dmidecode
}:

let
  src = callPackage ./src.nix { };
  pythonEnv = python3.withPackages (py: with py; [
    crcmod
    click
    progressbar2
    hid
  ]);
in
stdenv.mkDerivation {
  pname = "steamdeck-firmware";

  inherit src;
  inherit (src) version;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    # auto patchelf
    libkrb5
    zlib
    stdenv.cc.cc # libstdc++.so.6

    pythonEnv
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    cp -r usr/share/jupiter_bios $out/share
    cp -r usr/share/jupiter_bios_updater $out/share
    cp -r usr/share/jupiter_controller_fw_updater $out/share

    cp usr/bin/jupiter-biosupdate $out/bin
    sed -i "s|/usr/|$out/|g" $out/bin/jupiter-biosupdate
    wrapProgram $out/bin/jupiter-biosupdate \
      --prefix PATH : ${lib.makeBinPath [ jq dmidecode ]}

    cp usr/bin/jupiter-controller-update $out/bin
    sed -i "s|/usr/|$out/|g" $out/bin/jupiter-controller-update
    wrapProgram $out/bin/jupiter-controller-update \
      --prefix PATH : ${lib.makeBinPath [ jq pythonEnv ]}

    pushd $out/share/jupiter_bios_updater
    # Upstream comment:
    # > Remove gtk2 binary and respective build/start script - unused
    # > Attempts to use gtk2 libraries which are not on the device.
    rm h2offt-g H2OFFTx64-G.sh
    popd

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam Deck BIOS and controller firmware";
    license = licenses.unfreeRedistributableFirmware;
  };
}
