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
    rev = "d31bbe457f6e4ae641f555b48b9d64b6c6311191"; # jovian/v2
    hash = "sha256-T/9AhRYw6v/WvtUaTegBdvR3HWTUFDY6ztQtol9YDwI=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      src = ./jovian.patch;
    })
  ];

  nativeBuildInputs = [pkg-config];
  buildInputs = [libevdev];

  installPhase = ''
    runHook preInstall

    install -D -m 555 powerbuttond $out/bin/powerbuttond

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam Deck power button daemon";
    license = licenses.bsd2;
  };
}
