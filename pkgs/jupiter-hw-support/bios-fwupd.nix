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

# Board prefixes to build the output for.
, boards ? [
  "F7A" # Jupiter
  "F7G" # Galileo
]

# Directory containing the BIOS files.
, biosSource ? callPackage ./src.nix { }

# The release date of the BIOS for the fwupd manifest.
, releaseDate ? "1970-01-01"

# The human-readable version for the package.
, packageVersion ? jupiter-hw-support.src.version
}:

let
  version = if packageVersion != null then packageVersion else jupiter-hw-support.version;

in runCommand "steamdeck-bios-fwupd-${version}" {
  inherit boards biosSource releaseDate;

  nativeBuildInputs = [ gcab ];

  meta = with lib; {
    description = "Steam Deck BIOS for fwupd";
    license = licenses.unfreeRedistributableFirmware;
  };
} ''
  for board in $boards; do
    >&2 echo ":: Building archive for board '$board'"

    biosFile=$(find "$biosSource" -regextype posix-extended -type f -regex ".*/''${board}[0-9]{4}_sign.fd" | head -1)

    >&2 echo ":: Found BIOS file '$biosFile'"

    versionPair=$(basename "$biosFile" | sed 's/^.*'"$board"'\([0-9]\{2\}\)\([0-9]\{2\}\).*$/\1 \2/; t; q1')

    get_numeric_ver() { printf "%d" "0x00$100$2"; }
    export versionNumber=$(get_numeric_ver $versionPair)

    >&2 echo ":: Detected numeric BIOS version $versionNumber"

    uefi_guid=bbb1cf06-f7b9-4466-adcc-6b8815bd99e6

    # Run `fwupdtool hwids`
    # Manufacturer + Family + ProductName
    case "$board" in
      F7A)
        # Manufacturer: Valve
        # Family: Aerith
        # ProductName: Jupiter
        hwid=c92f10e2-b04e-59fd-9a1c-e9f354fe80d0
        model="LCD [Jupiter]"
        ;;
      F7G)
        # Manufacturer: Valve
        # Family: Sephiroth
        # ProductName: Galileo
        hwid=642e9dd3-94fe-5b66-a403-5e765427de87
        model="OLED [Galileo]"
        ;;
      *)
        >&2 echo ":: No GUID for board '$board'"
        exit 1
        ;;
    esac

    export model
    export board
    export hwid
    export uefi_guid
    export filename=$(basename "$biosFile")
    export sha1=$(sha1sum "$biosFile" | awk '{ print $1 }')
    export sha256=$(sha1sum "$biosFile" | awk '{ print $1 }')
    substituteAll ${./SteamDeckBIOS.metainfo.xml} SteamDeckBIOS.metainfo.xml

    >&2 echo ":: Generated metainfo file"

    archiveName=$(basename $biosFile | sed 's/_sign.*//')

    mkdir -p $out
    cp "$biosFile" .
    gcab -c $out/"$archiveName".cab SteamDeckBIOS.metainfo.xml "$filename"
  done
''
