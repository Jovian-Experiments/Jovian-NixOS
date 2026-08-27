{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.15-1.2";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.15-jupiter1.2";
    hash = "sha256-jgrGBN4GtRmEUvAWHY7WESgvQKvZNsfXuT35EJ+qUWc=";
  };
})
