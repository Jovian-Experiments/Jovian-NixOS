{
  stdenv,
  mesa,
  fetchFromGitHub,
}:
let
  version = "25.2.0";
  jupiterVersion = "steamos-25.6.0";
in
stdenv.mkDerivation {
  pname = "mesa";
  version = "${version}.${jupiterVersion}";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "mesa";
    rev = jupiterVersion;
    hash = "sha256-7plgicMRqR6hatOxMkhC/vVgmqw3M7J6OyU37HA68IM=";
  };

  inherit (mesa) buildInputs nativeBuildInputs propagatedBuildInputs;

  separateDebugInfo = true;

  mesonAutoFeatures = "auto";

  # See https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/jupiter-main/mesa-radv/PKGBUILD
  mesonFlags = [
    "-D android-libbacktrace=disabled"
    "-D b_ndebug=true"
    "-D gallium-drivers="
    "-D gallium-extra-hud=false"
    "-D gallium-rusticl=false"
    "-D gles1=disabled"
    "-D html-docs=disabled"
    "-D libunwind=disabled"
    "-D microsoft-clc=disabled"
    "-D valgrind=enabled"
    "-D video-codecs=all"
    "-D vulkan-drivers=amd"
    "-D vulkan-layers="
    # Jupiter specific options below:
    "-D b_lto=false"
    "-D gallium-vdpau=disabled"
    "-D gallium-va=disabled"
    "-D gallium-mediafoundation=disabled"
    "-D egl=disabled"
    "-D glx=disabled"
    "-D gbm=disabled"
    "-D gles2=disabled"
    "-D glvnd=disabled"
    "-D llvm=enabled"
    "-D lmsensors=disabled"
    "-D gpuvis=true"
    "-D radv-build-id=b0f01041524e5ffa6a44281db9150fe88eae8192"
  ];
}
