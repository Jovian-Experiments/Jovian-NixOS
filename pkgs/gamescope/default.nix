{ gamescope'
, fetchFromGitHub
, libei
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.5";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-TQAxTSN3g3MYPfcFfCTiN4pGY8W72DX8eDH14NAcnUc=";
  };

  buildInputs = old.buildInputs ++ [ libei ];
})
