{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.11-jupiter0-jovian2";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.11-jupiter0-jovian2";
    hash = "sha256-yg5Dg4sMQ9EoTPshwFaE17zda7aWvTIqthq4HBTxolc=";
  };
})
