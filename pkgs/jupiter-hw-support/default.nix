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

    cat > $out/share/alsa/ucm2/ucm.conf <<EOF
    Syntax 3

    UseCasePath {
        legacy {
            Directory "conf.d/acp5x"
            File "acp5x.conf"
        }
    }
    EOF

    # ALSA lib main.c:844:(execute_sequence) exec 'echo Main Verb Config EnableSequence' failed (exit code -8)
    # ALSA lib main.c:2573:(set_verb_user) error: failed to initialize new use case: HiFi
    # alsaucm: error failed to set _verb=HiFi: Exec format error
    sed -i 's|exec "echo|#exec "echo|g' $out/share/alsa/ucm2/conf.d/acp5x/HiFi*.conf

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
