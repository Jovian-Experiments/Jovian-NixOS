{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation {
  pname = "pagefind";
  version = "0.12.0";

  # Packaging is non-trivial due to missing Cargo.lock
  # So, for now, use the statically built release.
  src = fetchurl {
    url = "https://github.com/CloudCannon/pagefind/releases/download/v0.12.0/pagefind_extended-v0.12.0-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-IuQjjzwrP5Kz5jrWfT//0GR/qfJCwYYISCFoUfcWbpA=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -vp $out/bin
    ls -l
    mv -v pagefind_extended $out/bin/pagefind
  '';

  meta = {
    description = "Static low-bandwidth search at scale";
    homepage = "https://github.com/CloudCannon/pagefind";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [];
  };
}
