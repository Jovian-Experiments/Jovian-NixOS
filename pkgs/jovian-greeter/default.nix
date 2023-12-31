{ stdenv, python3, shellcheck, nodePackages }:

stdenv.mkDerivation {
  name = "jovian-greeter";

  outputs = [ "out" "helper" ];

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

    shellcheck ./consume-session
    pyright *.py

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm555 greeter.py $out/bin/jovian-greeter
    wrapPythonPrograms

    install -Dm555 ./consume-session $helper/lib/jovian-greeter/consume-session

    runHook postInstall
  '';
}
