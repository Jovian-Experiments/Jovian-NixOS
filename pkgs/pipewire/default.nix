{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.8-1.3";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.8-jupiter1.3";
    hash = "sha256-uPxuqcerXxPMIL6A/rQIwUuJD1aSSE0MKBojLt4LoHY=";
  };
})
