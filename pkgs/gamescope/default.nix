{ gamescope'
, fetchFromGitHub
, writeShellScriptBin
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.15.6";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-MSW949T0UL4p3XF5yhpwY6sMCSGQ9xA3LO5syu2C8tA=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ (writeShellScriptBin "git" "echo ${version}") ];
})
