{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.18-1.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.18-jupiter1.1";
    hash = "sha256-vnEXVwGiw4H5tbPib8WyKaSNw3IIk+EWp5RomX7Dw4Y=";
  };
})
