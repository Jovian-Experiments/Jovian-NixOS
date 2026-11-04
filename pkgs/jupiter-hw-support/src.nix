{
  stdenv,
  fetchFromGitHub,
  replaceVars,
  jovian-steam-protocol-handler,
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "jupiter-hw-support-source";
  version = "20261028.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-7vYNVzdbU71GVFoU/FYjUIb9PQQuA1vKL1RDmFkRMUs=";
  };

  patches = [
    (replaceVars ./automount-fix-system-paths.patch {
      handler = jovian-steam-protocol-handler;
      systemd = systemd;
    })
    # Remove `deck` username assumption
    ./0001-Jovian-Ensure-automounting-works-for-any-UID-1000-us.patch
    # Minor fixes against silly environments
    ./0001-steamos-automount-Harden-against-missing-run-media.patch
    ./0001-format-device-Harden-against-mountpoint-being-listed.patch
  ];

  # broken symlinks will be filled in later
  dontCheckForBrokenSymlinks = true;

  installPhase = ''
    cp -r . $out
  '';
}
