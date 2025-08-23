{
  lib,
  stdenv,
  llvmPackages,
  mesa,
  fetchFromGitHub,
}:
let
  version = "25.2.0";
  jupiterVersion = "radeonsi-25.2.0";
in
stdenv.mkDerivation {
  pname = "mesa-radeonsi-jupiter";
  version = "${version}.${jupiterVersion}";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "mesa";
    rev = jupiterVersion;
    hash = "sha256-yftXfcJHndS9bcyiAaGf3YkLHw7/aIzfVnJMLsYmyNo=";
  };

  # Jovian: tell Mesa where to find libclang
  patches = [ ./opencl.patch ];

  inherit (mesa)
    buildInputs
    nativeBuildInputs
    propagatedBuildInputs
    # inherit fixups so we get correct paths in EGL driver/Vulkan layer manifests
    postFixup
    ;

  separateDebugInfo = true;

  mesonAutoFeatures = "auto";

  # See https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/jupiter-main/mesa-radeonsi/PKGBUILD
  mesonFlags = [
    "-D android-libbacktrace=disabled"
    "-D b_ndebug=true"
    "-D gallium-drivers=radeonsi,llvmpipe,zink,iris,i915"
    "-D gallium-extra-hud=true"
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
    "-D radeonsi-build-id=057e67ad037d628991eb985a05023c20caeed78d"

    # Jovian: build with our libgbm
    "-D libgbm-external=true"
    # Jovian: inject correct libclang path
    "-D clang-libdir=${lib.getLib llvmPackages.clang-unwrapped}/lib"
  ];
}
