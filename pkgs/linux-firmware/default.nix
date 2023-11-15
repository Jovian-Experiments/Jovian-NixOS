{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20231113.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-aaTFdotKyTjPK9iuPs91Dqvk9521E4VIcggxYIRlffQ=";
  };

  outputHash = "sha256-puzVKvwV0fCDz+M6cm18Xq4W0qAFgtFu3okSnsj9RNU=";
})
