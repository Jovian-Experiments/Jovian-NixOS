{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cec-audio-control";
  version = "0.1.0";

  src = fetchFromGitLab {
    domain = "gitlab.steamos.cloud";
    owner = "holo";
    repo = "cec-audio-control";
    rev = "37f1f520c78790f3e9406b908e452c217c37788d";
    hash = "sha256-OJLeXAcJINr/OXPCy6WhDm0oYK26ncXec20smwuyoxc=";
  };

  cargoHash = "sha256-YDtAv24Vjg9Nc6IHYnmVFq2OjQtonOnbIXmKGOLVGNA=";

  doCheck = false;

  strictDeps = true;

  postPatch = ''
    substituteInPlace data/cec-audio-control.service \
      --replace-warn "/usr/bin/cec-audio-control" "$out/bin/cec-audio-control"
  '';

  postInstall = ''
    install -d -m 755 $out/lib/systemd/user
    install -m 644 data/cec-audio-control.service $out/lib/systemd/user
    install -m 644 data/cec-audio-control.socket $out/lib/systemd/user
  '';

  meta = {
    description = "HDMI CEC volume and mute control";
    longDescription = ''
      PipeWire external volume control backend that forwards volume and
      mute changes over HDMI-CEC to a connected TV/receiver.
    '';
    license = lib.licenses.mit;
    mainProgram = "cec-audio-control";
  };
})
