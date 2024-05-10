{ callPackage, fetchFromGitHub, git, libxkbcommon, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage" "git" "libxkbcommon"])).overrideAttrs (old: {
  version = "0.7.2.rc3.r11.g31f2ca5";

  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    rev = "31f2ca5e306d7bad502ae70d346f0309e1f4764b";
    hash = "sha256-gqqSWbwKMepLVhG8kP00V/vIvVMjWeAezUg2TZzc9p0=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
  buildInputs = old.buildInputs ++ [ libxkbcommon ];
})
