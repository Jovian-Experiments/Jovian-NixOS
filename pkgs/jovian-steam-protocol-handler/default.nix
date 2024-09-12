{
  steamPackages,
}:
# FIXME: this is a hack, replace with a better implementation
# Investigate magic socket?
steamPackages.steam-fhsenv.overrideAttrs(old: {
  runScript = "~/.steam/root/ubuntu12_32/steam";
})
