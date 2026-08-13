{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.15-1.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.15-jupiter1.1";
    hash = "sha256-Lg7XZBByG18ypBwipMyaPWEDvejTiLha3gAiUyxkTfM=";
  };
})
