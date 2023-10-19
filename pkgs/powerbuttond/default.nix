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
    rev = "v2";
    hash = "sha256-syeVkiD42QM3wkE0iqfS5+Z3hqh1reqCWGnTR3BGXV4=";
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
