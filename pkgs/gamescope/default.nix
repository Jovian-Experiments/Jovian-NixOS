{ gamescope'
, fetchFromGitHub
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.16.2";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-vKl2wYAt051+1IaCGB1ylGa83WTS+neqZwtQ/4MyCck=";
  };

  patches = old.patches or [] ++ [
    ./32bit-crash-fix.patch
  ];
})
