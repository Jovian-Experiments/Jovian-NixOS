{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20260825.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-laNbfwqz4sAIfEOQlD9gG0GsCi7e7y6BlrZrot+EqhQ=";
  };

  # clobber nixpkgs patches
  patches = [];
})
