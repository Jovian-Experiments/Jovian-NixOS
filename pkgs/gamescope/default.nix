{ gamescope'
, fetchFromGitHub
, writeShellScriptBin
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.15.7";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-ugbZaYqXrBO2XSJMubISB1XXPW0RPetqmrC8gn8cfm8=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ (writeShellScriptBin "git" "echo ${version}") ];
})
