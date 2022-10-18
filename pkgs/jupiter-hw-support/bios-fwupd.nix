# To install the BIOS update:
#
# 1. Disable Secure Boot, or have a `fwupd-efi` with `fwupdx64.efi.signed`.
# 2. Set `OnlyTrusted=false` in `/etc/fwupd/daemon.conf`.
#    (WARNING: This may make your device less secure!)
# 3. Run `sudo fwupdmgr install /path/to/bios.cab`

{ lib
, runCommand
, callPackage
, jupiter-hw-support
, gcab

# The following parameters are for your enjoyment of flashing custom/older BIOSes:

# The BIOS file (e.g., "F7A0110_sign.fd") or a directory containing it.
, biosFile ? jupiter-hw-support.src

# The BIOS version (e.g., "0110").
# If null, parsed from the BIOS file name.
, biosVersion ? null

# The release date of the BIOS for the fwupd manifest.
, releaseDate ? "1970-01-01"

# The human-readable version for the package.
, packageVersion ? jupiter-hw-support.src.version
}:

let
  version = if packageVersion != null then packageVersion else jupiter-hw-support.version;

in runCommand "steamdeck-bios-fwupd-${version}" {
  inherit biosFile biosVersion releaseDate;

  nativeBuildInputs = [ gcab ];

  meta = with lib; {
    description = "Steam Deck BIOS for fwupd";
    license = licenses.unfreeRedistributableFirmware;
  };
} ''
  if [[ -d "$biosFile" ]]; then
    biosFile=$(find "$biosFile" -regextype posix-extended -type f -regex ".*/F7A.*_sign.fd" | head -1)
  fi

  >&2 echo ":: Found BIOS file $biosFile"

  if [[ -z "$biosVersion" ]]; then
    versionPair=$(basename "$biosFile" | sed 's/^.*F7A\([0-9]\{2\}\)\([0-9]\{2\}\).*$/\1 \2/; t; q1')
  else
    versionPair=$(echo "$biosVersion" | sed 's/^\([0-9]\{2\}\)\([0-9]\{2\}\)$/\1 \2/; t; q1')
  fi

  get_numeric_ver() { printf "%d" "0x00$100$2"; }
  export versionNumber=$(get_numeric_ver $versionPair)

  >&2 echo ":: Detected numeric BIOS version $versionNumber"

  export filename=$(basename "$biosFile")
  export sha1=$(sha1sum "$biosFile" | awk '{ print $1 }')
  export sha256=$(sha1sum "$biosFile" | awk '{ print $1 }')
  substituteAll ${./SteamDeckBIOS.metainfo.xml} SteamDeckBIOS.metainfo.xml

  >&2 echo ":: Generated metainfo file"
  cat -n SteamDeckBIOS.metainfo.xml

  mkdir -p $out
  cp "$biosFile" .
  gcab -c $out/bios.cab SteamDeckBIOS.metainfo.xml "$filename"
''
