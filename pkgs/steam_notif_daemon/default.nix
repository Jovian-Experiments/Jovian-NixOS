{
  lib,
  stdenv,
  fetchFromGitHub,
  substituteAll,
  meson,
  ninja,
  pkg-config,
  systemd,
  curl,
  jovian-steam-protocol-handler,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "steam_notif_daemon";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "steam_notif_daemon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mtG2D+FEzTtYi3XnFKifhHLC5h8ApB2XREn74AVCbWc=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      src = ./jovian.patch;
    })
  ];

  mesonFlags = ["-Dsd-bus-provider=libsystemd"];

  nativeBuildInputs = [pkg-config meson ninja];
  buildInputs = [systemd curl];

  meta = with lib; {
    description = "Steam notification daemon";
    license = licenses.mit;
  };
})
