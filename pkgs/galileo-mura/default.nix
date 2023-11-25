{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, wrappersDir ? "/run/wrappers/bin"
}:

stdenv.mkDerivation rec {
  pname = "galileo-mura";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "galileo-mura";
    rev = "v${version}";
    hash = "sha256-mO43q3oZPGrPjQyFFJLjVgZZTyxhn+8Szcn2FzGvkHk=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  postInstall = ''
    sed -i 's|/usr/bin/galileo-mura-extractor|${wrappersDir}/galileo-mura-extractor|g' $out/bin/galileo-mura-setup
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/Jovian-Experiments/galileo-mura";
    license = licenses.mit;
    mainProgram = "galileo-mura";
    platforms = platforms.all;
  };
}
