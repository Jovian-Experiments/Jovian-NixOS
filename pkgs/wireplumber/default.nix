{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: rec {
  version = "0.4.14-dev24";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "refs/tags/${version}";
    hash = "sha256-J4gU3jr4IuCU5y40t4mEPKjeBmm0TQDVgqFTR3xoXRU=";
  };
})
