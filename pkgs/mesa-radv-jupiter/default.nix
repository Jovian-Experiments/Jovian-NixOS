{ stdenv, mesa, fetchFromGitHub }:
let
  version = "26.2.0";
  jupiterVersion = "steamos-26.05.3";
in stdenv.mkDerivation {
  pname = "mesa";
  version = "${version}.${jupiterVersion}";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "mesa";
    rev = jupiterVersion;
    hash = "sha256-gFyZIyrOqfVGF4CzE3BndsPLv0i8kh3PN4YgvFWFF54=";
  };

  inherit (mesa) buildInputs nativeBuildInputs propagatedBuildInputs;

  separateDebugInfo = true;

  mesonAutoFeatures = "auto";

  # See https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/jupiter-main/mesa-radv/PKGBUILD
  mesonFlags = [
    "-D android-libbacktrace=disabled"
    "-D b_ndebug=true"
    "-D gallium-mediafoundation=disabled"
    "-D gles1=disabled"
    # "-D intel-rt=enabled"
    "-D libunwind=disabled"
    "-D microsoft-clc=disabled"
    "-D valgrind=enabled"
    "-D video-codecs=all"
    # Jupiter specific options below:
    "-D gallium-drivers="
    "-D gallium-extra-hud=false"
    "-D gallium-rusticl=false"
    "-D html-docs=disabled"
    "-D vulkan-drivers=amd"
    "-D vulkan-layers=anti-lag"
    "-D b_lto=false"
    "-D gallium-va=disabled"
    "-D egl=disabled"
    "-D glx=disabled"
    "-D gbm=disabled"
    "-D gles2=disabled"
    "-D glvnd=disabled"
    "-D llvm=disabled"
    "-D lmsensors=disabled"
    "-D gpuvis=true"
    "-D display-info=disabled"
    "-D amdgpu-virtio=true"
    "-D intel-rt=disabled"
    "-D sysprof=false"
    "-D tools=drm-shim"
    "-D radv-build-id=aff0430f0f151fde3f595ff0c110f7bd415e2236"
  ];
}
