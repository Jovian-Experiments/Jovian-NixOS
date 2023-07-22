{ stdenv, python3, coreutils, makeWrapper }:

stdenv.mkDerivation {
  name = "jovian-greeter";

  src = ./.;

  buildInputs = [ python3 makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

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
