{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, glib
, libevdev
}:

stdenv.mkDerivation {
  pname = "deckbd";
  version = "0-unstable-2024-07-01";

  src = fetchFromGitHub {
    owner = "Ninlives";
    repo = "deckbd";
    rev = "1d2c71f2c096fbfa42624dd820a9d11a35c64826";
    hash = "sha256-Svp/5Mo/XkiptbTM3E4QhSRxC6rMeF0t3eTq9BUjLbs=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ glib libevdev ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Steam Deck controller keymapper";
    homepage = "https://github.com/Ninlives/deckbd";
    license = lib.licenses.gpl3Only;
    mainProgram = "deckbd";
    platforms = lib.platforms.linux;
  };
}
