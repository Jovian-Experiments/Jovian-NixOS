{ lib
, stdenv
, callPackage
, python3
}:

let
  src = callPackage ./src.nix { };
  pythonEnv = python3.withPackages (py: with py; [
    evdev
  ]);
in
stdenv.mkDerivation {
  pname = "jupiter-hw-support";

  inherit src;
  inherit (src) version;

  buildInputs = [ pythonEnv ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r usr/lib/hwsupport $out/lib

    mkdir -p $out/share
    cp -r usr/share/alsa $out/share

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
