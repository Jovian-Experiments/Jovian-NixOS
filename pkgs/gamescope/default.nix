{ 
  gamescope',
  fetchFromGitHub,
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.16.30";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-Rg0/P0kd6hmBTcWU9IbSXwV0qjJU+Qu/RHewONc7iqg=";
  };
})
