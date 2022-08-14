{ lib, stdenv, fetchFromGitHub, ncurses }:

stdenv.mkDerivation {
  pname = "sdgyrodsu";
  version = "unstable-2022-08-22";

  src = fetchFromGitHub {
    owner = "kmicki";
    repo = "SteamDeckGyroDSU";
    rev = "6244cbc3ec55687efa9b6ade32d6c04637065003";
    sha256 = "sha256-3hMSgFqNV9GyShwU0aB3tEpx82SUBHGl9jpYDYDua8k=";
  };

  buildInputs = [ ncurses ];

  makeFlags = [ "NOPREPARE=1" "release" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r bin/release/sdgyrodsu $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cemuhook DSU server for the Steam Deck Gyroscope";
    homepage = "https://github.com/kmicki/SteamDeckGyroDSU";
    license = licenses.mit;
  };
}
