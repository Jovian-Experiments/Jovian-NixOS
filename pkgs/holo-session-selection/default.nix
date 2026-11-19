{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "holo-session-selection";
  version = "1.1-1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "PKGBUILDs-mirror";
    rev = "holo-main/holo-session-selection-${finalAttrs.version}";
    hash = "sha256-Uzg2XdcK6ZbPibuEeoSrB8P5T3FkaBnuJv1omTM674o=";
  };

  # SDDM config set via NixOS module instead
  installPhase = ''
    runHook preInstall

    install -D -m755 holo-session-select $out/bin/holo-session-select

    runHook postInstall
  '';
})
