{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation(finalAttrs: {
  pname = "linux-firmware-holo";
  version = "20261005.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware-holo";
    rev = "${finalAttrs.version}";
    hash = "sha256-cs0QBV/wlypof5dCDpsd88PTs6ov5O4Ek9E/xQ7I+JI=";
  };

  makeFlags = [
    "DESTDIR=$(out)"
    "FIRMWAREDIR=/lib/firmware"
  ];
})
