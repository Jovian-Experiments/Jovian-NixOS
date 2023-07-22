{ stdenv, python3, shellcheck, nodePackages, makeWrapper }:

stdenv.mkDerivation {
  name = "jovian-greeter";

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

    mkdir -p $out/{bin,libexec,share/jovian-greeter}

    cp ./consume-session $out/libexec
    cp *.py $out/share/jovian-greeter
    makeWrapper ${python3}/bin/python $out/bin/jovian-greeter \
      --add-flags "$out/share/jovian-greeter/greeter.py" \
      --set CONSUME_SESSION_HELPER "$out/libexec/consume-session"

    runHook postInstall
  '';
}
