{
  buildFHSEnv,
  writeShellScript,
}:
# Just enough fhsenv to run just enough of Steam to actually send a URL to the _real_ Steam.
# FIXME: this is a hack, replace with a better implementation
# Investigate magic socket?
buildFHSEnv {
  name = "jovian-steam-protocol-handler";
  
  multiArch = true;
  multiPkgs = pkgs: with pkgs; [
    glibc
    xorg.libX11
    xorg.libxcb
    xorg.libXau
    xorg.libXdmcp
  ];
  
  runScript = writeShellScript "jovian-steam-protocol-handler-impl" ''
    exec ~/.steam/root/ubuntu12_32/steam "$@"
  '';
}
