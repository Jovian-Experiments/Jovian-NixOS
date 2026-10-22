{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.8-1.6";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.8-jupiter1.6";
    hash = "sha256-302uLXBElLdHIXfmT3FnYji1Iae4J9tgnPHckvgLjIE=";
  };
})
