{ gamescope'
, fetchFromGitHub
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.16";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-tijFVOIMW+nkot/uRP0PNZBYZkZMMt1PcAN5+3SWzW4=";
  };
})
