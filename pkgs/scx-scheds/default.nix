{
  rustPlatform,
  fetchFromGitHub,
  llvmPackages,
  pkg-config,
  elfutils,
  zlib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "scx-scheds";
  version = "1.1.4.linux.steamos.2";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "scx-scheds";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1KWhyXNy8m4f8pmgNNnIHMIAAt1W+GaUPiaaDouXYb8=";
  };

  cargoHash = "sha256-Dvsqlu0m4kC8DFqGFaD9OAJH81NcfWrtca9Edr4sfWQ=";

  nativeBuildInputs = [
    llvmPackages.clang
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    elfutils
    zlib
  ];

  cargoBuildFlags = [ "--package=scx_lavd" ];

  doCheck = false;

  # not supported on BPF
  hardeningDisable = [ "zerocallusedregs" ];
})
