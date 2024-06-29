{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, glib
, libevdev
}:

stdenv.mkDerivation {
  pname = "deckbd";
  version = "0-unstable-2023-03-16";

  src = fetchFromGitHub {
    owner = "Ninlives";
    repo = "deckbd";
    rev = "327a8c91159e1b7faa2f12b5e11060b2eb9947a8";
    hash = "sha256-T7iYl1xWtk39XMUUWm1pK0WVm5UK656HmqWHKDmJ220=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ glib libevdev ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Steam Deck controller keymapper";
    homepage = "https://github.com/Ninlives/deckbd";
    license = lib.licenses.unfree; # https://github.com/Ninlives/deckbd/issues/1
    mainProgram = "deckbd";
    platforms = lib.platforms.linux;
  };
}
