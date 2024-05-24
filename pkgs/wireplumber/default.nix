{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: rec {
  version = "0.5.2-jupiter1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = version;
    hash = "sha256-GaLxoNOyVFvLPeR9D4k4iXDspUcfHjOh+CNZjkmUKXw=";
  };
})
