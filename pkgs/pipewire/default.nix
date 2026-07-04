{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.4-1.10";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.4-jupiter1.10";
    hash = "sha256-rBq/wALrIWBT/UVCqXH6r+i45HGw9WdL+IfXR2eDfmQ=";
  };
})
