{ gamescope'
, fetchFromGitHub
, writeShellScriptBin
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.15.9";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-+BRinPyh8t9HboT0uXPEu+sSJz9qCZshlfzDfZDA41Q=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ (writeShellScriptBin "git" "echo ${version}") ];
})
