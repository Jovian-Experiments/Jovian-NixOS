{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20250311.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-oO6/cqEL6NGAqF/Ttr+vhl0WTHX8ijUB66vPwz+FSBY=";
  };
})
