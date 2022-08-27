{ lib, fetchFromGitHub, buildLinux, ... } @ args:

let
  inherit (lib)
    concatStringsSep
    splitVersion
    take
    versions
  ;

  kernelVersion = "5.13.0";
  vendorVersion = "valve24";
in
buildLinux (args // rec {
  version = "${kernelVersion}-${vendorVersion}";

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor version;

  structuredExtraConfig = with lib.kernel; {
    #
    # From the downstream packaging
    # -----------------------------
    #

    ##
    ## Neptune stuff
    ##

    # Doesn't build on latest tag, not used in neptune hardware (?)
    SND_SOC_CS35L36 = no;
    # Update this to  = yes to workaround initialization issues and deadlocks when loaded as module;
    # The cs35l41 / acp5x drivers in EV2 fail IRQ initialization with this set to  = yes, changed back
    SPI_AMD = module;

    # Works around issues with the touchscreen driver
    PINCTRL_AMD = yes;

    JUPITER = module;
    SND_SOC_CS35L41 = module;
    SND_SOC_CS35L41_SPI = module;

    SND_SOC_AMD_ACP5x = module;
    SND_SOC_AMD_VANGOGH_MACH = module;
    SND_SOC_WM_ADSP = module;
    SND_SOC_CS35L41_I2C = no;
    SND_SOC_NAU8821 = module;
    # Enabling our ALS, only in jupiter branches at the moment
    LTRF216A = module;

    # PARAVIRT options have overhead, even on bare metal boots. They can cause
    # spinlocks to not be inlined as well. Either way, we don't intend to run this
    # kernel as a guest, so this also clears out a whole bunch of
    # virtualization-specific drivers.
    HYPERVISOR_GUEST = lib.mkForce no;

    #
    # Fallout from the vendor-set options
    # -----------------------------------
    #
    KVM_GUEST = lib.mkForce (option no);
    MOUSE_PS2_VMMOUSE = lib.mkForce (option no);
  };

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux";
    rev = version;
    hash = "sha256-zTc6qmKImrn/ChtK1Fu3VhaKaeiGMLHakgIahKddTMs=";
  };
} // (args.argsOverride or { }))
