{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libevdev,
}:
stdenv.mkDerivation {
  pname = "powerbuttond";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "powerbuttond";
    rev = "3d3b41afb181bf7cdc2ee3b36f84934cf2bd379d"; # jovian/multi
    hash = "sha256-4Q/brmwl3mb8WJYkMejM2IorwVlIb7L2RnIMWczfb8A=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace '/usr/lib/hwsupport/powerbuttond' '/usr/bin/powerbuttond' \
      --replace '/usr/' '/'
  '';

  nativeBuildInputs = [pkg-config];
  buildInputs = [libevdev];

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "Steam Deck power button daemon";
    license = licenses.bsd2;
  };
}
