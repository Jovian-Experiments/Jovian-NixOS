{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20260827.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-PBGQIo2ORxWxGwuo0eHDZI0mEDk7BCpyJlEPkoQdp1I=";
  };

  # clobber nixpkgs patches
  patches = [];
})
