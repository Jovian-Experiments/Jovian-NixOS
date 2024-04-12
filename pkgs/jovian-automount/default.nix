{
  writeShellApplication,
  steam,
  util-linux,
  coreutils,
  udisks,
  gawk,
  gnused,
  gnugrep,
  ed,
  systemd,
  lib,
  ...
}: let
  inherit (lib) readFile;
in
  writeShellApplication {
    name = "jovian-automount";
    runtimeInputs = [systemd coreutils util-linux gawk udisks gnused gnugrep];
    text = readFile ./script.sh;
  }
