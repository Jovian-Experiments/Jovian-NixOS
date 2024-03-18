{ lib, fetchFromGitHub, fetchpatch, buildLinux, ... } @ args:

let
  inherit (lib) versions;

  kernelVersion = "6.1.52";
  vendorVersion = "valve19";
in
buildLinux (args // rec {
  version = "${kernelVersion}-${vendorVersion}";

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor version;

  kernelPatches = (args.kernelPatches or []) ++ [
    {
      # Enable all Bluetooth LE PHYs by default
      # See comment in https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/d594fbf6bea8f0bace6dafca1799632579cd772b/PKGBUILD
      name = "enable-all-ble-phys";
      patch = fetchpatch {
        url = "https://github.com/Jovian-Experiments/linux/commit/288c90224eec55d13e786844b7954ef060752089.patch";
        hash = "sha256-iDEZBowNsfeECzM6AWVOGBKurbEGSiWWa9PQIV6kVVY=";
      };
    }
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

    # Doesn't build on latest tag, not used in neptune hardware (?)
    SND_SOC_CS35L36 = no;
    # Update this to =y to workaround initialization issues and deadlocks when loaded as module
    # The cs35l41 / acp5x drivers in EV2 fail IRQ initialization with this set to =y, changed back
    SPI_AMD = module;
    # Jovian: not a real option?
    # CONFIG_I2C_AMD=m;

    # Works around issues with the touchscreen driver
    PINCTRL_AMD = yes;

    SND_SOC_AMD_ACP5x = module;
    SND_SOC_AMD_VANGOGH_MACH = module;
    SND_SOC_WM_ADSP = module;
    SND_SOC_CS35L41 = module;
    SND_SOC_CS35L41_SPI = module;
    # Jovian: Vendor fragment disables the option, forced enabled by actual kernel config.
    # SND_SOC_CS35L41_I2C = no;
    SND_SOC_NAU8821 = module;
    SND_SOC_MAX98388 = module;

    SND_SOC_AMD_ACP3x = no;
    # Jovian: unused?
    # SND_SOC_AMD_RV_RT5682_MACH = no;
    SND_SOC_AMD_RENOIR = no;
    # Jovian: unused?
    # SND_SOC_AMD_RENOIR_MACH = no;

    SND_SOC_AMD_ACP6x = no;
    # Jovian: unused?
    # SND_SOC_AMD_YC_MACH = no;
    SND_AMD_ACP_CONFIG = module;
    SND_SOC_AMD_ACP_COMMON = module;
    # Jovian: unused?
    # SND_SOC_AMD_ACP_PDM = no;
    # SND_SOC_AMD_ACP_I2S = no;
    # SND_SOC_AMD_ACP_PCM = no;
    SND_SOC_AMD_ACP_PCI = no;
    SND_AMD_ASOC_RENOIR = no;
    SND_AMD_ASOC_REMBRANDT = no;
    SND_SOC_AMD_MACH_COMMON = module;
    SND_SOC_AMD_LEGACY_MACH = no;

    SND_SOC_AMD_SOF_MACH = module;
    SND_SOC_AMD_RPL_ACP6x = no;
    SND_SOC_AMD_PS = no;
    # Jovian: unused?
    # SND_SOC_AMD_PS_MACH = no;

    SND_SOC_SOF = module;
    SND_SOC_SOF_PROBE_WORK_QUEUE = yes;
    SND_SOC_SOF_IPC3 = yes;
    SND_SOC_SOF_INTEL_IPC4 = yes;

    SND_SOC_SOF_AMD_TOPLEVEL = module;
    SND_SOC_SOF_AMD_COMMON = module;
    SND_SOC_SOF_AMD_RENOIR = no;
    SND_SOC_SOF_AMD_REMBRANDT = no;
    SND_SOC_SOF_AMD_VANGOGH = module;

    # Steam Deck HID driver
    HID_STEAM = module;
    STEAM_FF = yes;

    # Enable Ambient Light Sensor
    LTRF216A = module;

    # Enable Steam Deck MFD driver, replaces Jupiter ACPI platform driver (CONFIG_JUPITER)
    MFD_STEAMDECK = module;
    EXTCON_STEAMDECK = module;
    LEDS_STEAMDECK = module;
    SENSORS_STEAMDECK = module;

    # Enable support for AMDGPU color calibration features
    DRM_AMD_COLOR_STEAMDECK = yes;

    # PARAVIRT options have overhead, even on bare metal boots. They can cause
    # spinlocks to not be inlined as well. Either way, we don't intend to run this
    # kernel as a guest, so this also clears out a whole bunch of
    # virtualization-specific drivers.
    HYPERVISOR_GUEST = lib.mkForce no;
    PARAVIRT_TIME_ACCOUNTING = lib.mkForce (option no);

    # Disable some options enabled in ArchLinux 6.1.12-arch1 config
    X86_AMD_PSTATE = lib.mkForce no;
    # Jovian: meh
    # CONFIG_HAVE_RUST=n

    # Build as module to experiment with toggling
    TCG_TPM = module;

    # Galileo Analogix I2C magic module thing
    DRM_ANALOGIX_ANX7580 = module;

    # Per Colin at Quectel
    CFG80211_CERTIFICATION_ONUS = yes;
    ATH_REG_DYNAMIC_USER_REG_HINTS = yes;

    # Jovian: fix fallout from the vendor-set options
    DRM_AMD_DC_SI = lib.mkForce (option no);
    DRM_AMD_DC_DCN = lib.mkForce (option no);
    DRM_AMD_DC_HDCP = lib.mkForce (option no);
    DRM_HYPERV = lib.mkForce (option no);
    DRM_VMWGFX_FBCON = lib.mkForce (option no);
    KVM_GUEST = lib.mkForce (option no);
    MOUSE_PS2_VMMOUSE = lib.mkForce (option no);
  };

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux";
    rev = version;
    hash = "sha256-uS/0RAaZt99EA3mn6Vso0kAGrqvnJovNEc1nfPLdey8=";

    # Sometimes the vendor doesn't update the EXTRAVERSION tag.
    # Let's fix it up in post.
    # ¯\_(ツ)_/¯
    # Also, `postPatch` on the kernel doesn't compose in `buildLinux`.
    # ¯\_(ツ)_/¯
    postFetch = ''
      (
      echo ":: Fixing-up EXTRAVERSION with actual tag"
      cd $out
      sed -i -e 's/^EXTRAVERSION =.*/EXTRAVERSION = -${vendorVersion}/g' Makefile
      )
    '';
  };
} // (args.argsOverride or { }))
