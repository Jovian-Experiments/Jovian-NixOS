{
  lib,
  stdenv,
  fetchFromGitHub,
  substituteAll,
  pkg-config,
  libevdev,
  jovian-steam-protocol-handler,
}:
stdenv.mkDerivation {
  pname = "powerbuttond";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "powerbuttond";
    rev = "ef6d214295a38f186bba9a80cc6f48c055700e3a"; # jovian/multi
    hash = "sha256-SD8NpiBIIvI59/HtV19lsJ8/SdBOoyO2rH1OVmDX5Q8=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      src = ./jovian.patch;
    })
  ];

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
