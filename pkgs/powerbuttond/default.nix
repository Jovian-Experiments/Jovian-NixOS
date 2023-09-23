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
  version = "1.0";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "powerbuttond";
    rev = "v1";
    hash = "sha256-2MvmkclbPIu8qIoZRd+4Kr+H7nO1xUWJ2JrCJC7gzK4=";
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
