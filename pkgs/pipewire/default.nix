{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.8-1.8";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.8-jupiter1.8";
    hash = "sha256-fIDrqoLKdv36C0HsfYT5YGJjewE/dAeExGnxT8l68Fk=";
  };
})
