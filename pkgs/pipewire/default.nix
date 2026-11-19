{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.8-1.9";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.8-jupiter1.9";
    hash = "sha256-ZtWqVb0txQAcduDoILSOyWIr23GQId+gbEi2cv71Zjk=";
  };
})
