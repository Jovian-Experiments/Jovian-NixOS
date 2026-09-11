{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20260910.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-+X7MlvMfs0a6jUpYnzD2ropA+vvYNu/f/6xA2LUg1mg=";
  };

  # clobber nixpkgs patches
  patches = [];
})
