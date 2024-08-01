{ gamescope'
, fetchFromGitHub
, lcms2
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.26";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-vCPKySLB1D9oKgCrYrXqt/s0hV+/ocuWOrcDUzKbdKI=";
  };

  buildInputs = old.buildInputs ++ [ lcms2 ];
})
