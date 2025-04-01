{
  writeShellScript,
  steam-run,
}:
# FIXME: this is a hack, replace with a better implementation
# Investigate magic socket?
writeShellScript "jovian-steam-protocol-handler" ''
  exec ${steam-run}/bin/steam-run ~/.steam/root/ubuntu12_32/steam "$@"
''
