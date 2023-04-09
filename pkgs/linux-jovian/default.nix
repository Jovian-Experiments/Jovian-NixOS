{ lib, fetchFromGitHub, buildLinux, ... } @ args:

let
  inherit (lib)
    concatStringsSep
    splitVersion
    take
    versions
  ;

  kernelVersion = "6.1.21";
  vendorVersion = "valve1";
in
buildLinux (args // rec {
  version = "${kernelVersion}-${vendorVersion}";

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor version;

  kernelPatches = (args.kernelPatches or []) ++ [
  ];

  structuredExtraConfig = with lib.kernel; {
    #
    # From the downstream packaging
    # -----------------------------
    #

    ##
    ## Neptune stuff
    ##

    #
    # Disable Radeon, SI and CIK support since not required for Vangogh GPU
    #
    DRM_AMDGPU_CIK = lib.mkForce no;
    DRM_AMDGPU_SI = lib.mkForce no;
    DRM_RADEON = no;

    # Jovian-NixOS: nah, let's use NixOS defaults here.
    # #
    # # Use xz instead of zstd to save space
    # #
    # KERNEL_XZ = yes;
    # KERNEL_ZSTD = no;
    # MODULE_COMPRESS_XZ = yes;
    # MODULE_COMPRESS_ZSTD = no;

    # Doesn't build on latest tag, not used in neptune hardware (?)
    SND_SOC_CS35L36 = no;
    # Update this to =y to workaround initialization issues and deadlocks when loaded as module
    # The cs35l41 / acp5x drivers in EV2 fail IRQ initialization with this set to =y, changed back
    SPI_AMD = module;

    # Works around issues with the touchscreen driver
    PINCTRL_AMD = yes;

    SND_SOC_AMD_ACP5x = module;
    SND_SOC_AMD_VANGOGH_MACH = module;
    SND_SOC_WM_ADSP = module;
    SND_SOC_CS35L41 = module;
    SND_SOC_CS35L41_SPI = module;
    # Jovian-NixOS: Vendor fragment disables the option, forced enabled by actual kernel config.
    # SND_SOC_CS35L41_I2C = no;
    SND_SOC_NAU8821 = module;

    # Enable Ambient Light Sensor
    LTRF216A = module;

    # Enable Steam Deck MFD driver, replaces Jupiter ACPI platform driver (CONFIG_JUPITER)
    MFD_STEAMDECK = module;
    EXTCON_STEAMDECK = module;
    LEDS_STEAMDECK = module;
    SENSORS_STEAMDECK = module;

    # PARAVIRT options have overhead, even on bare metal boots. They can cause
    # spinlocks to not be inlined as well. Either way, we don't intend to run this
    # kernel as a guest, so this also clears out a whole bunch of
    # virtualization-specific drivers.
    HYPERVISOR_GUEST = lib.mkForce no;

    #
    # Fallout from the vendor-set options
    # -----------------------------------
    #
    DRM_AMD_DC_SI = lib.mkForce (option no);
    DRM_HYPERV = lib.mkForce (option no);
    KVM_GUEST = lib.mkForce (option no);
    MOUSE_PS2_VMMOUSE = lib.mkForce (option no);

    # Workaround for regression with AMD SEV configs enabled
    # https://github.com/NixOS/nixpkgs/pull/203908#issuecomment-1360956830
    CRYPTO_DEV_CCP = lib.mkForce no;
    AMD_MEM_ENCRYPT = lib.mkForce no;
    KVM_AMD_SEV = lib.mkForce (option no);
    SEV_GUEST = lib.mkForce (option no);

    # Does not build with it set, and not supported by the vendor
    # https://twitter.com/Plagman2/status/1623024896887631875
    X86_AMD_PSTATE = lib.mkForce no;
    X86_AMD_PSTATE_UT = lib.mkForce (option no);

    # Temporary workaround pending pahole fixes
    # https://aur.archlinux.org/packages/linux-mainline-git#comment-903098
    DEBUG_INFO_BTF = lib.mkForce no;
  };

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux";
    rev = version;
    hash = "sha256-ypYhz1kD+enIl31yhjlzqDnd3RqQcyc+7Udlw1Y5iSM=";
  };
} // (args.argsOverride or { }))
