{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
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

  meta = with lib; {
    description = "";
    homepage = "https://github.com/Jovian-Experiments/galileo-mura";
    license = licenses.mit;
    mainProgram = "galileo-mura";
    platforms = platforms.all;
  };
}
