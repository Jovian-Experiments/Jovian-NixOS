{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20240503.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-Jh3+N7T1Ws6jKE7+TvkG7ND6U9eV2RJlxgX2rRzP0QY=";
  };

  outputHash = "sha256-cB/47mBp9sAFVSWNkMEckMeX3tXRBoISwb+xDHWVqeU=";
})
