{
  decky-loader,
}:
decky-loader.overridePythonAttrs(old: rec {
  pname = "decky-loader";
  version = "3.2.10-pre1";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-YLv9rC9cDH+LoVTIc4jSn/tZV3S+jC37RrnK2b/q++c=";
  };

  pnpmDeps = old.pnpmDeps.override {
    inherit version src;
    hash = "sha256-w4UFsNqy8fYjpQ5jgPRQ4bfVZJb3aitYUsnf4PP8Itc=";
  };
})
