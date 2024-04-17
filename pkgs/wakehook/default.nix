{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  systemd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wakehook";
  version = "1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wakehook";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3eCGxA3nexlaVl5M1OOa5i2hYObwUIze4zslLUaofIE=";
  };

  nativeBuildInputs = [pkg-config];
  buildInputs = [systemd];

  installPhase = ''
    runHook preInstall

    install -Dm555 wakehook $out/bin/wakehook

    runHook postInstall
  '';

  meta = with lib; {
    description = "SteamOS CEC power management daemon";
    license = licenses.mit;
  };
})
