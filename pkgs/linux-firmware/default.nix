{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: rec {
  version = "20240917.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-${version}";
    hash = "sha256-mqBREldC1/nRzjDyPCneeMhDSW4w4VTH2K4F2IDYVxo=";
  };

  # FIXME: workaround newer linux-firmware needing `install dedup`
  # and this linux-firmware being too old to have `dedup`
  installTargets = [ "install" ];
})
