{ lib, stdenv, python3, plymouth, shellcheck, nodePackages, rustPlatform }:

stdenv.mkDerivation {
  name = "jovian-greeter";

  src = ./.;

  nativeBuildInputs = [ python3.pkgs.wrapPython ];
  buildInputs = [ python3 ];
  pythonPath = [ python3.pkgs.systemd ];

  nativeCheckInputs = [
    shellcheck
    nodePackages.pyright
  ];

  checkPhase = ''
    runHook preCheck

    pyright *.py

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm555 greeter.py $out/bin/jovian-greeter
    wrapPythonPrograms --prefix PATH : ${lib.makeBinPath [ plymouth ]}

    runHook postInstall
  '';

  passthru.helper = rustPlatform.buildRustPackage {
    pname = "jovian-consume-session";
    version = "0.0.1";

    src = ./consume-session;

    cargoLock.lockFile = ./consume-session/Cargo.lock;

    # avoid a second rebuild
    doCheck = false;
  };
}
