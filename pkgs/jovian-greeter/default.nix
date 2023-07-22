{ stdenv, python3 }:

stdenv.mkDerivation {
  name = "jovian-greeter";

  src = ./.;

  buildInputs = [ python3 ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./greeter.py $out/bin/jovian-greeter

    runHook postInstall
  '';
}
