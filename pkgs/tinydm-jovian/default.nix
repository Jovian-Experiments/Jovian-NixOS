{ stdenv, lib, fetchFromGitHub, shellcheck }:

stdenv.mkDerivation rec {
  pname = "tinydm-jovian";
  version = "2023-07-15";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "tinydm-jovian";
    rev = "1ea1c388037ab77f9b5c855056903bc154460df0";
    hash = "sha256-tJyV8TPbxH24mcea7yLWuol4zWJbT7x6fvfT8lUHfe4=";
  };

  nativeBuildInputs = [ shellcheck ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    shellcheck tinydm-run-session.sh
    install -Dm755 tinydm-run-session.sh $out/bin/tinydm-run-session

    runHook postInstall
  '';
}
