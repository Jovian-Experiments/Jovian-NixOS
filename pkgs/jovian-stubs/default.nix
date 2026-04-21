{ stdenv }:
stdenv.mkDerivation {
  name = "jovian-stubs";

  buildCommand = ''
    install -D -m 755 ${./holo-factory-reset-config} $out/bin/holo-factory-reset-config
    install -D -m 755 ${./holo-firmware-update} $out/bin/holo-firmware-update
    install -D -m 755 ${./holo-reboot} $out/bin/holo-reboot
    install -D -m 755 ${./holo-select-branch} $out/bin/holo-select-branch
    install -D -m 755 ${./holo-session-select} $out/bin/holo-session-select
    install -D -m 755 ${./holo-update} $out/bin/holo-update

    install -D -m 755 ${./pkexec} $out/bin/pkexec
    install -D -m 755 ${./sudo} $out/bin/sudo

    # apparently still used by Steam (see jupiter-legacy-support)
    install -D -m 755 ${./holo-select-branch} $out/bin/steamos-select-branch
    install -D -m 755 ${./holo-update} $out/bin/steamos-update
  '';
}
