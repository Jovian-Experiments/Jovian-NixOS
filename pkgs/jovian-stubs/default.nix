{ stdenv }:
stdenv.mkDerivation {
  name = "jovian-stubs";

  buildCommand = ''
    install -D -m 755 ${./steamos-factory-reset-config} $out/bin/steamos-factory-reset-config
    install -D -m 755 ${./steamos-firmware-update} $out/bin/steamos-firmware-update
    install -D -m 755 ${./steamos-mandatory-update} $out/bin/steamos-mandatory-update
    install -D -m 755 ${./steamos-reboot} $out/bin/steamos-reboot
    install -D -m 755 ${./steamos-select-branch} $out/bin/steamos-select-branch
    install -D -m 755 ${./steamos-session-select} $out/bin/steamos-session-select
    install -D -m 755 ${./steamos-update} $out/bin/steamos-update

    install -D -m 755 ${./pkexec} $out/bin/pkexec
    install -D -m 755 ${./sudo} $out/bin/sudo
  '';
}
