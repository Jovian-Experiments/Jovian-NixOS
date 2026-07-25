{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.14-1.7";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.14-jupiter1.7";
    hash = "sha256-sgoSKSyO0mpHMJHFw0qsPB+2uPnuJfn8nJBzxZKEsDQ=";
  };
})
