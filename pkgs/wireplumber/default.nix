{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: rec {
  version = "0.4.14-dev23";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "refs/tags/${version}";
    hash = "sha256-+z7BQlRu8XYxE5vEFCfentdrQNuCP0RnQHiPx8/Yfl8=";
  };
})
