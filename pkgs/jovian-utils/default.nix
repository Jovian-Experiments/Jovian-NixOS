{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "jovian-utils";
  version = "1.0.0";

  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}