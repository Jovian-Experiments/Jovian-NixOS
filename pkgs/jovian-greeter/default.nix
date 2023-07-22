{ stdenv, python3, shellcheck, nodePackages, makeWrapper }:

stdenv.mkDerivation {
  name = "jovian-greeter";

  outputs = [ "out" "helper" ];

  src = ./.;

  buildInputs = [ python3 shellcheck nodePackages.pyright makeWrapper ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    shellcheck ./consume-session
    pyright *.py

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/jovian-greeter}
    cp *.py $out/lib/jovian-greeter
    makeWrapper ${python3}/bin/python $out/bin/jovian-greeter \
      --add-flags "$out/lib/jovian-greeter/greeter.py"

    mkdir -p $helper/lib/jovian-greeter
    cp ./consume-session $helper/lib/jovian-greeter

    runHook postInstall
  '';
}
