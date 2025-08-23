{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs (_: rec {
  version = "20250731.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-AC+dKMSG9+qDEZnG92AdxkTiDzmSkyRR4R159ok/9lc=";
  };
})
