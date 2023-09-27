{
  writeShellScript,
  steamPackages,
}:
# FIXME: this is a hack, replace with a better implementation
# Investigate magic socket?
writeShellScript "jovian-steam-protocol-handler" ''
  exec ${steamPackages.steam-fhsenv.run}/bin/steam-run ~/.steam/root/ubuntu12_32/steam "$@"
''
