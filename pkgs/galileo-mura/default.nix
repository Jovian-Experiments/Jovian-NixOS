{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, resholve
, bash
, writeText
, coreutils
, findutils
, gawk
, gnugrep
, gnused
, gnutar
, wget
, xorg
}:
let
  solution = {
    scripts = [ "bin/galileo-mura-download" "bin/galileo-mura-setup" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      findutils
      gawk
      gnugrep
      gnused
      gnutar
      wget
      xorg.xprop
      "${placeholder "out"}/bin"
    ];

    execer = [
      "cannot:${wget}/bin/wget"
      "cannot:${placeholder "out"}/bin/galileo-mura-download"
    ];

    fake.external = ["galileo-mura-extractor"];

    prologue = "${writeText "gamescope-session-prologue" ''
      export PATH=/run/wrappers/bin:$PATH
    ''}";
  };
in
stdenv.mkDerivation rec {
  pname = "galileo-mura";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "galileo-mura";
    rev = "v${version}";
    hash = "sha256-eM4UHYCgj2vwK8cxh6KKta7gpFjX/7bwS7VJaKsBG7c=";
  };

  patches = [./home.patch];

  nativeBuildInputs = [
    meson
    ninja
  ];

  postInstall = ''
    substituteInPlace $out/bin/galileo-mura-setup \
      --replace-fail /usr/bin/galileo-mura-extractor galileo-mura-extractor
    ${resholve.phraseSolution "galileo-mura" solution}
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/Jovian-Experiments/galileo-mura";
    license = licenses.mit;
    mainProgram = "galileo-mura";
    platforms = platforms.all;
  };
}
