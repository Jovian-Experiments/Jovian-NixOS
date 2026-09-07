{ lib, stdenv, python3, fetchFromGitHub }:

stdenv.mkDerivation(finalAttrs: {
  pname = "jupiter-fan-control";
  version = "20260902.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-fan-control";
    rev = finalAttrs.version;
    hash = "sha256-75DW3cMxakZ11CZUF4bvYV8l+d24JWleEiGRMW+kMSM=";
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

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam Deck (Jupiter) userspace fan controller";

    # PKGBUILD says MIT, but PID.py is licensed under GPLv3+
    license = licenses.gpl3Plus;
  };
})
