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
  version = "1.1.3.linux.steamos.2";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "scx-scheds";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BL7vYgXXki78L2HHxVplHGkdL7tUGD+uiZT0InhEecE=";
  };

  cargoHash = "sha256-Litgyq6baN1L9hUQI0TTp7oDN3bAF42xqzHSrYhdpn0=";

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
