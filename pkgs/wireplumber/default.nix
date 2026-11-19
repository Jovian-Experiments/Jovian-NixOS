{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs (_: {
  version = "0.5.18-1.4";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.18-jupiter1.4";
    hash = "sha256-nQ4H28tBr6CyS2jfgSa5QPbYs0sVoCpdZE2loTisJTQ=";
  };
})
