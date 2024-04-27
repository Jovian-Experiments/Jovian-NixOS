{ mesa, fetchFromGitHub }:
let
  version = "24.1.0";
  jupiterVersion = "steamos-24.4.0";
in (mesa.override {
  galliumDrivers = [];
  vulkanDrivers = ["amd"];
  vulkanLayers = [];
  enableGalliumNine = false;
  enableOSMesa = false;
  enableOpenCL = false;
}).overrideAttrs(old: {
  version = "${version}.${jupiterVersion}";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "mesa";
    rev = jupiterVersion;
    hash = "sha256-fWtEH8Ln1QZKMa7Y8sLexWyQYhNIuMhIUQPy198Oopg=";
  };

  # Clobber all the existing patches
  patches = [];

  # Filter out nixpkgs disk cache key, we trust vendor here
  mesonFlags = old.mesonFlags ++ [
    # Disable all the Gallium stuff that we don't need because no drivers
    "-Degl=disabled"
    "-Dglvnd=disabled"
    "-Dgallium-vdpau=disabled"
    "-Dgallium-va=disabled"
    "-Dgallium-xa=disabled"

    # Disable libgbm to save space
    "-Dgbm=disabled"

    # Disable intel-clc to avoid libclc dependency
    "-Dintel-clc=system"
    "-Dintel-rt=disabled"

    # Vendor sets this
    "-Dradv-build-id=64474a6475eb8af2b44ef334793fd58ad89875f6"
  ];
})
