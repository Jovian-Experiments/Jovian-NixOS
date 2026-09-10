{ lib
, fetchFromGitHub
, nodejs
, pnpm_11
, fetchPnpmDeps
, pnpmConfigHook
, python3
, coreutils
, psmisc
}:
python3.pkgs.buildPythonPackage rec {
  pname = "decky-loader";
  version = "3.2.8";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-Y2dMTKLXtZAyXuWhnS/jbqjCYyWvSChslt/YxIBbWXw=";
  };

  # confuses our pnpm tooling
  postPatch = ''
    rm frontend/pnpm-workspace.yaml
  '';

  pnpmDeps = fetchPnpmDeps {
    fetcherVersion = 4;
    inherit pname version src;

    # copy here because of sourceRoot
    postPatch = ''
      rm pnpm-workspace.yaml
    '';

    pnpm = pnpm_11;
    sourceRoot = "${src.name}/frontend";
    hash = "sha256-OHimg85kcjk+Tq1Yv8TA9CfPDVzxdgPpzTi2mxyPs4s=";
  };

  pyproject = true;

  pnpmRoot = "frontend";

  nativeBuildInputs = [
    nodejs
    pnpm_11
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
