{ gamescope'
, fetchFromGitHub
, lcms
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.27";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-8Fpr0puLaiJxWXbM798DLDu64iMYZsbDhGMy9mxwiiM=";
  };

  buildInputs = old.buildInputs ++ [ lcms ];
})
