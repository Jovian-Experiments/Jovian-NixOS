{
  decky-loader,
}:
decky-loader.overridePythonAttrs(old: rec {
  pname = "decky-loader";
  version = "3.2.8-pre1";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-zqHqg9EuWXss+4yNVtIRCv1oq6/hPlhRB1oe9q7xLEc=";
  };

  pnpmDeps = old.pnpmDeps.override {
    inherit version src;
    hash = "sha256-OHimg85kcjk+Tq1Yv8TA9CfPDVzxdgPpzTi2mxyPs4s=";
  };
})
