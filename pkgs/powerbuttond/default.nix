{
  lib,
  stdenv,
  fetchFromGitHub,
  substituteAll,
  pkg-config,
  libevdev,
  udev,
  jovian-steam-protocol-handler,
}:
stdenv.mkDerivation {
  pname = "powerbuttond";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "powerbuttond";
    rev = "v3.0"; # jovian/multi
    hash = "sha256-MJIq7zilItTS05EiCzU8fJv5sY0gUdEwpNAt5bPREzk=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      src = ./jovian.patch;
    })
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail /usr/lib/hwsupport/steamos-powerbuttond /usr/bin/steamos-powerbuttond \
      --replace-fail /usr/ /

    substituteInPlace steamos-powerbuttond.service \
      --replace-fail /usr/lib/hwsupport/steamos-powerbuttond $out/bin/steamos-powerbuttond
  '';

  nativeBuildInputs = [pkg-config];
  buildInputs = [libevdev udev];

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "Steam Deck power button daemon";
    license = licenses.bsd2;
  };
}
