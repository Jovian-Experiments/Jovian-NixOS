{
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  rustc,
  cargo,
  rustPlatform,
  systemd,
  dbus,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-gamescope";
  version = "0.1.38.c99b9f7";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "xdg-desktop-portal-gamescope";
    rev = "c99b9f7a6357e4753391c13933ef8bbfc3a9b7bb";
    hash = "sha256-Lu6JUNhTZ6s/LbQc0DRf9GHdGvW0slNGULAvarVHHGs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-wdl+cIqBv/DfBQDEU+1Q+rCrsOIH9yhEg4AgF7rGnGg=";
  };

  env.PKG_CONFIG_DBUS_1_SESSION_BUS_SERVICES_DIR = "${placeholder "out"}/share/dbus-1/services";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustc
    cargo
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    systemd
    dbus
  ];
})
