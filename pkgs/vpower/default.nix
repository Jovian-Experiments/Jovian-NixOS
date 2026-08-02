{
  rustPlatform,
  fetchFromGitHub,
  lm_sensors,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vpower";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "vpower";
    tag = finalAttrs.version;
    hash = "sha256-KV3VPEmXUzG2dJCO8aKPkhBDj37WI+izToVM7AWoc80=";
  };

  postPatch = ''
    substituteInPlace vpower.service \
      --replace-fail /usr/lib/vpower $out/bin/vpower
  '';

  cargoHash = "sha256-+hcVK9PS4WGVu6xcbfXIeI2QKj6tdgGj15Doi5/3mA8=";

  buildInputs = [
    lm_sensors
  ];

  postInstall = ''
    install -Dm644 vpower.service "$out/lib/systemd/system/vpower.service"
  '';
})
