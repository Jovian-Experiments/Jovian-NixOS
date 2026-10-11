{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.8-1.5";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.8-jupiter1.5";
    hash = "sha256-Gmi73YqmQiB2M6mCXdJYK8qD25G79HYIELyfwG0i61I=";
  };
})
