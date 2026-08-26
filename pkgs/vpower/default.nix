{
  rustPlatform,
  fetchFromGitHub,
  lm_sensors,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vpower";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "vpower";
    tag = finalAttrs.version;
    hash = "sha256-8a26gbwN4moWRPyIdNxiLrsqxtDDBymR9wTADxqhb8o=";
  };

  postPatch = ''
    substituteInPlace vpower.service \
      --replace-fail /usr/lib/vpower $out/bin/vpower
  '';

  cargoHash = "sha256-EGrnmeOvlN34FRafsnSzs1DVTedtTk/IzCMhrto3tkE=";

  buildInputs = [
    lm_sensors
  ];

  postInstall = ''
    install -Dm644 vpower.service "$out/lib/systemd/system/vpower.service"
  '';
})
