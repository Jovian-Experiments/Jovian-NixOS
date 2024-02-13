{ mesa, fetchFromGitHub }:
let
  version = "23.3.0";
  jupiterVersion = "steamos-23.9.9";
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
    hash = "sha256-mVo5KZw3P8HQ4U7ykIY9rmWlSwLQI0G1bjPQpTh9ZkI=";
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
    "-Dradv-build-id=0fc57c2cf625a235fe81e41877a40609c43e451a"
  ];
})
