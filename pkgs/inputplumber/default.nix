{
  inputplumber',
  fetchFromGitHub,
  rustPlatform,
}:
inputplumber'.overrideAttrs rec {
  version = "0.78.0";

  src = fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "InputPlumber";
    tag = "v${version}";
    hash = "sha256-wa05/gStEbXUZLvokY1N4k4f4/cPm2Kolbf+AF479lU=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-lScpMua5czwmnz/+fz+UrgZSWHwRNP7zB317xJS+6gs=";
  };
}
