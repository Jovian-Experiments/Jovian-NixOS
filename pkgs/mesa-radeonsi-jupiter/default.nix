{ 
  lib,
  stdenv,
  llvmPackages,
  mesa,
  fetchFromGitHub,
}:
let
  version = "26.1.2";
  jupiterVersion = "radeonsi-26.1.2";
in
stdenv.mkDerivation {
  pname = "mesa-radeonsi-jupiter";
  version = "${version}.${jupiterVersion}";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "mesa";
    rev = jupiterVersion;
    hash = "sha256-PmaoWVaO2ufHykjcDoQczLQ2/oYrpzzLWBV1sJ3J48U=";
  };

  inherit (mesa) 
    buildInputs
    propagatedBuildInputs
  ;

  # Mesa 26.1 depends on normal libclc, but nixpkgs Mesa is now at 26.2,
  # which uses mesa-libclc, and normal libclc is gone.
  # Since we only need libclc to build mesa-clc, just yoink it from
  # the host (nixpkgs flavored) Mesa - it works well enough.
  nativeBuildInputs = mesa.nativeBuildInputs ++ [ mesa.cross_tools ];

  # inherit fixups so we get correct paths in EGL driver/Vulkan layer manifests,
  # but fix up the fixup so we don't patchelf a thing we don't have
  postFixup = lib.replaceString "$opencl/lib/libRusticlOpenCL.so" "" mesa.postFixup;

  separateDebugInfo = true;

  mesonAutoFeatures = "auto";
  
  # See https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/jupiter-main/mesa-radeonsi/PKGBUILD
  mesonFlags = [
    "-D android-libbacktrace=disabled"
    "-D b_ndebug=true"
    "-D gallium-drivers=radeonsi,llvmpipe,zink,iris,i915"
    "-D gallium-extra-hud=true"
    "-D mesa-clc=system"
    "-D gallium-rusticl=false"
    "-D gles1=disabled"
    "-D html-docs=disabled"
    "-D libunwind=disabled"
    "-D microsoft-clc=disabled"
    "-D valgrind=enabled"
    "-D video-codecs=all"
    "-D vulkan-drivers=intel,swrast"
    "-D vulkan-layers=device-select,intel-nullhw,overlay,screenshot,vram-report-limit"
    "-D gallium-mediafoundation=disabled"
    "-D amdgpu-virtio=true"
    "-D radeonsi-build-id=6dc25ea2b40438949c158970db654d9db358d5b1"

    # Jovian: build with our libgbm
    "-D libgbm-external=true"
  ];
}
