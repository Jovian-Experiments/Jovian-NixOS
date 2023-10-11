{ stdenv }:
stdenv.mkDerivation {
  name = "jovian-stubs";

  buildCommand = ''
    install -D -m 755 ${./steamos-factory-reset-config} $out/bin/steamos-factory-reset-config
    install -D -m 755 ${./steamos-reboot} $out/bin/steamos-reboot
    install -D -m 755 ${./steamos-select-branch} $out/bin/steamos-select-branch
    install -D -m 755 ${./steamos-update} $out/bin/steamos-update
  '';
}
