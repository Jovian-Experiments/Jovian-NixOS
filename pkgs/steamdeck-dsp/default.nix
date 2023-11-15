{ stdenv
, lib
, fetchFromGitHub
, boost
, lv2
, faust2lv2
, which
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "steamdeck-dsp";
  version = "0.38";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "steamdeck-dsp";
    rev = finalAttrs.version;
    sha256 = "sha256-7WZ0r0X24ok5fNSBV1ATqtl/aoiq6iDFV/NnVznh/Cc=";
  };

  nativeBuildInputs = [
    faust2lv2
    which
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/include/boost "${boost.dev}/include/boost" \
      --replace /usr/include/lv2 "${lv2.dev}/include/lv2"
  '';

  preInstall = ''
    export DEST_DIR="$out"
  '';

  postInstall = ''
    mv -vt $out $out/usr/*
    rmdir -v $out/usr
  '';

  # ¯\_(ツ)_/¯
  # Leaky wrappers I guess.
  dontWrapQtApps = true;

  meta = {
    description = "Steamdeck Audio Processing";
    # Actual license of all parts unclear.
    # https://github.com/Jovian-Experiments/steamdeck-dsp/blob/0.38/LICENSE
    license = [ lib.licenses.gpl3 faust2lv2.meta.license ];
  };
})
