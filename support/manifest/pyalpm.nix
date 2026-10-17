{
  lib,
  buildPythonPackage,
  fetchFromGitLab,
  pkg-config,
  meson-python,
  pytest,
  libarchive,
  pacman,
}:

buildPythonPackage rec {
  pname = "pyalpm";
  version = "0.11.1";
  pyproject = true;

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = "pyalpm";
    rev = version;
    hash = "sha256-Q1Ufcjn2aalLqqn19JRP39CzjYyVjyHSTse7wLA3f5w=";
  };

  nativeBuildInputs = [
    pkg-config
    meson-python
  ];

  nativeCheckInputs = [
    pytest
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
