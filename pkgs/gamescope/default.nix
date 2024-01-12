{ gamescope'
, fetchFromGitHub
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.13.19";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = "refs/tags/${version}";
    fetchSubmodules = true;
    hash = "sha256-WKQgVbuHvTbZnvTU5imV35AKZ4AF0EDsdESBZwVH7+M=";
  };
})
