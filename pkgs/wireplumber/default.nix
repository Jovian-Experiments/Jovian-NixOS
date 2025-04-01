{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.7-jupiter1.1";
    hash = "sha256-DuU/TEPYBk2pnIaJyNRF84RDu0VKW+ZGATunkChxBxo=";
  };
})
