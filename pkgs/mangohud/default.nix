{ callPackage, fetchFromGitHub, git, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage" "git"])).overrideAttrs (old: {
  version = "0.7.0.r68";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    rev = "ea725ed1d2000d5409e701dc770282b28e80d5e6";
    hash = "sha256-ZvpAQsM7KV3fQLxNBzWNCYVSjR0ILESIgZq9AigiqGg=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
})
