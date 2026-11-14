{
  rustPlatform,
  fetchFromGitHub,
  lm_sensors,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vpower";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "vpower";
    tag = finalAttrs.version;
    hash = "sha256-FhS839t1coyoIeRvceIIR6oJUhT+hvQHno1fq5FlheA=";
  };

  postPatch = ''
    substituteInPlace vpower.service \
      --replace-fail /usr/lib/vpower $out/bin/vpower
  '';

  cargoHash = "sha256-P7ZNPzE1wfh6LlxKDd54eOcexgE/N6W07npFTyYFpVA=";

  buildInputs = [
    lm_sensors
  ];

  postInstall = ''
    install -Dm644 vpower.service "$out/lib/systemd/system/vpower.service"
  '';
})
