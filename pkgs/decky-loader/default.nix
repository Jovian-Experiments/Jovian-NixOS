{ lib
, fetchFromGitHub
, nodejs
, pnpm
, python3
, coreutils
, psmisc
}:
python3.pkgs.buildPythonPackage rec {
  pname = "decky-loader";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-IFop3SbXYCzYdHGRK08v8uPL4sSAHelCrIEc8HquZmg=";
  };

  pyproject = true;

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    sourceRoot = "${src.name}/frontend";
    hash = "sha256-IX7WI0q30Wa54sSpPQu9SarxijS9BQFgo6Lkw12E6GI=";
  };

  pnpmRoot = "frontend";

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
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

  passthru.python = python3;

  meta = with lib; {
    description = "A plugin loader for the Steam Deck";
    homepage = "https://github.com/SteamDeckHomebrew/decky-loader";
    platforms = platforms.linux;
    license = licenses.gpl2Only;
  };
}
