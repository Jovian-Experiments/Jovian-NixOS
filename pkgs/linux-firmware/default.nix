{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20260712.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-UDtxeWCknIdnwPBTso3VFJFnpURGtPQnfxZjxA4n8Vk=";
  };

  # clobber nixpkgs patches
  patches = [];
})
