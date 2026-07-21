{ lib
, fetchFromGitHub
, nodejs
, pnpm_10
, fetchPnpmDeps
, pnpmConfigHook
, python3
, coreutils
, psmisc
}:
python3.pkgs.buildPythonPackage rec {
  pname = "decky-loader";
  version = "3.2.6";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-p1bkLsZedTZ29POqdaXvVpPXzg9kBTKgUxkkEAyAkT0=";
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

    pnpm = pnpm_10;
    sourceRoot = "${src.name}/frontend";
    hash = "sha256-X1L8JYG5hgYMmfg0aa8XhkRU6/oFrYTPiXDIyq77puE=";
  };

  pyproject = true;

  pnpmRoot = "frontend";

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
  ];

  preBuild = ''
    cd frontend
    pnpm build
    cd ../backend
  '';

  build-system = with python3.pkgs; [ 
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = with python3.pkgs; [
    aiohttp
    aiohttp-cors
    aiohttp-jinja2
    certifi
    multidict
    packaging
    setproctitle
    watchdog
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ coreutils psmisc ]}"
  ];

  pythonRelaxDeps = [
    "aiohttp-cors"
    "packaging"
    "watchdog"
  ];

  passthru.python = python3;

  meta = with lib; {
    description = "A plugin loader for the Steam Deck";
    homepage = "https://github.com/SteamDeckHomebrew/decky-loader";
    platforms = platforms.linux;
    license = licenses.gpl2Only;
  };
}
