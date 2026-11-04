{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs (_: {
  version = "0.5.18-1.3"; # 1.3 is a rebuild

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.18-jupiter1.2";
    hash = "sha256-40yFTAeH9nLWzidswxY9QhMl0TZpwcTBh51SV64s4pk=";
  };
})
