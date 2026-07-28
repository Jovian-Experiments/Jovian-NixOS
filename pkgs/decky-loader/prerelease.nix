{
  decky-loader,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_9,
}:
decky-loader.overridePythonAttrs rec {
  pname = "decky-loader";
  version = "3.2.8-pre1";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-zqHqg9EuWXss+4yNVtIRCv1oq6/hPlhRB1oe9q7xLEc=";
  };

  # confuses our pnpm tooling
  postPatch = ''
    rm frontend/pnpm-workspace.yaml
  '';

  pnpmDeps = fetchPnpmDeps {
    fetcherVersion = 3;
    inherit pname version src;

    # copy here because of sourceRoot
    postPatch = ''
      rm pnpm-workspace.yaml
    '';

    pnpm = pnpm_9;
    sourceRoot = "${src.name}/frontend";
    hash = "sha256-WgKycKbaZv9lovoo0IaCuV41qS4zUqm4vZxsMQBUdNk=";
  };
}
