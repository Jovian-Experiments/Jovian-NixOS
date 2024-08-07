{ gamescope'
, fetchFromGitHub
, lcms
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.28";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-0dE98/Tr1yDPEvQ/n/44i3sv78lXp/rnnIKalKHIxUY=";
  };

  buildInputs = old.buildInputs ++ [ lcms ];
})
