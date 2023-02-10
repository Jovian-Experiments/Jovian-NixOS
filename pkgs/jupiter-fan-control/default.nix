{ lib, stdenv, python3, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "jupiter-fan-control";
  version = "20230209.1";

  # TODO: Replace with https://gitlab.steamos.cloud/jupiter/jupiter-fan-control
  # once it becomes public
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-fan-control";
    rev = version;
    sha256 = "sha256-9sNJdR0t8GW0hcSNylTK5YcflPltfqyN9KnPos1YcA0=";
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
}
