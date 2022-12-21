{ lib, fetchFromGitHub, buildLinux, ... } @ args:

let
  inherit (lib)
    concatStringsSep
    splitVersion
    take
    versions
  ;

  kernelVersion = "6.0.9";
  vendorVersion = "valve1";
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

    SND_SOC_AMD_ACP5x = module;
    SND_SOC_AMD_VANGOGH_MACH = module;
    SND_SOC_WM_ADSP = module;
    SND_SOC_CS35L41 = module;
    SND_SOC_CS35L41_SPI = module;
    SND_SOC_NAU8821 = module;

    # Enable Ambient Light Sensor
    LTRF216A = module;

    # STEAMDECK modules are implicitly enabled (m)

    HYPERVISOR_GUEST = lib.mkForce no;

    #
    # Fallout from the vendor-set options
    # -----------------------------------
    #
    KVM_GUEST = lib.mkForce (option no);
    DRM_HYPERV = lib.mkForce (option no);
    MOUSE_PS2_VMMOUSE = lib.mkForce (option no);
  };

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux";
    rev = "${kernelVersion}-${vendorVersion}";
    hash = "sha256-YdAMyLlN9Nf5lvlaNRaDVErtZvA+43oswj0taMNP6e4=";
  };
} // (args.argsOverride or { }))
