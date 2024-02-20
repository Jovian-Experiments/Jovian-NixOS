{ mesa, fetchFromGitHub }:
let
  version = "24.1.0";
  jupiterVersion = "steamos-24.1.2";
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
    hash = "sha256-nTEmtP1pjpWeaXQsXn0sHeFKkhNIBTLoJClkAPakkT4=";
  };

  # Clobber all the existing patches
  patches = [];

  # Filter out nixpkgs disk cache key, we trust vendor here
  mesonFlags = old.mesonFlags ++ [
    # Disable all the Gallium stuff that we don't need because no drivers
    "-Degl=disabled"
    "-Dglvnd=false"
    "-Dgallium-vdpau=disabled"
    "-Dgallium-va=disabled"
    "-Dgallium-xa=disabled"

    # Disable libgbm to save space
    "-Dgbm=disabled"

    # Disable intel-clc to avoid libclc dependency
    "-Dintel-clc=disabled"

    # Vendor sets this
    "-Dradv-build-id=e60f3bf3a400d3b96b0ce331633fd21e9bafd2a8"
  ];
})
