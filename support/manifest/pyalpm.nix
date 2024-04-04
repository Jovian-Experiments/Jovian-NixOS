{ lib
, buildPythonPackage
, fetchFromGitLab
, pkgconfig
, setuptools
, wheel
, libarchive
, pacman
}:

buildPythonPackage rec {
  pname = "pyalpm";
  version = "0.10.9";
  pyproject = true;

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = "pyalpm";
    rev = version;
    hash = "sha256-hn28B/WAkLnFOTL+CstnjJdrcmE0Gat+1DXk8DffCWc=";
  };

  nativeBuildInputs = [
    pkgconfig
    setuptools
    wheel
  ];

  buildInputs = [
    libarchive
    pacman
  ];

  pythonImportsCheck = [ "pyalpm" ];

  meta = with lib; {
    description = "Python 3 bindings for libalpm";
    homepage = "https://gitlab.archlinux.org/archlinux/pyalpm";
    changelog = "https://gitlab.archlinux.org/archlinux/pyalpm/-/blob/${src.rev}/NEWS";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
