{ gamescope'
, fetchFromGitHub
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.15.1";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-KhYmaf8esSmHL4o0zdbdqIUwcMQ28XIknvgV+aHyufM=";
  };
})
