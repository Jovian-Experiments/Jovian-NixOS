{
  lib,
  fetchFromGitHub,
  nodejs,
  pnpm_9,
  python3,
  coreutils,
  psmisc,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "decky-loader";
  version = "3.1.10";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-XHKkitgVaBZRQXFOK+K+4fKnsB2SOKTm/QGkDLcMIjg=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    fetcherVersion = 1;
    inherit pname version src;
    sourceRoot = "${src.name}/frontend";
    hash = "sha256-HS3PWLxIoH/1/ir510eOLEMVMEdXBOhvYHTZBMnCB2Q=";
  };

  pyproject = true;

  pnpmRoot = "frontend";

  nativeBuildInputs = [
    nodejs
    pnpm_9.configHook
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
    "--prefix PATH : ${
      lib.makeBinPath [
        coreutils
        psmisc
      ]
    }"
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
