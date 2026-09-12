{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fremont-hw-support";
  version = "20260807.1";

  src = fetchFromGitHub {
    owner = "duckysocks22";
    repo = "fremont-hw-support";
    rev = "fremont-${finalAttrs.version}";
    hash = "sha256-WXn37xArjWR9PJYWClgpJ1K1bpWQ1ivlBaqjAvAqZ6E=";
  };
  
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fwupd/remotes.d
    cp -r usr/share/fwupd/remotes.d/fremont $out/share/fwupd/remotes.d
    runHook postInstall
  '';

  meta = with lib; {
    description = ''
      SteamOS Hardware Support for the Steam Machine (fremont)
    '';
    license = licenses.unfreeRedistributableFirmware;
  };
})
