{
  mangohud',
  libdrm,
  libxi,
  vulkan-loader,
}:
# we only really need mangoapp here, not the layers, so don't waste time on 32-bit ones
(mangohud'.override { lowerBitnessSupport = false; }).overrideAttrs (old: {
  version = "0.8.4.r235";

  src = old.src.override {
    tag = null;
    rev = "8d76620f71e92e5f686940404bfa7625a9034213";
    hash = "sha256-mVaTJE/G+w5Hr0VFQZrymV1kEkiKmciETK4r2/r/elY=";
  };

  patches = builtins.filter (
    p: (builtins.match "hardcode-dependencies.patch" (toString p)) != null
  ) old.patches;

  mesonFlags = old.mesonFlags ++ [ "-Dwith_mangohud_next=false" ];

  buildInputs = old.buildInputs ++ [
    libdrm
    libxi
    vulkan-loader
  ];
})
