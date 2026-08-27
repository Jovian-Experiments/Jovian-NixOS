{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.8-1.4";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.8-jupiter1.4";
    hash = "sha256-1Z9OI/2RZNefyMsCh8y60X2NhVkeYo/YjQO5x2HXnJU=";
  };
})
