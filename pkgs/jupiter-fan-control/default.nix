{ lib, stdenv, python3, fetchFromGitHub }:

stdenv.mkDerivation(finalAttrs: {
  pname = "jupiter-fan-control";
  version = "20231114.3";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-fan-control";
    rev = finalAttrs.version;
    sha256 = "sha256-gbIqsrTHp8T6tcmeAsgDKEb37EqUfSLOLhtrSzBY8YE=";
  };

  buildInputs = [
    (python3.withPackages (py: with py; [
      pyyaml
    ]))
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r usr/share/jupiter-fan-control $out/share
    sed -i "s|/usr/share/|$out/share/|g" $out/share/jupiter-fan-control/fancontrol.py

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam Deck (Jupiter) userspace fan controller";

    # PKGBUILD says MIT, but PID.py is licensed under GPLv3+
    license = licenses.gpl3Plus;
  };
})
