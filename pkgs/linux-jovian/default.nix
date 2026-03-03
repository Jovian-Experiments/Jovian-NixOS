{ lib, fetchFromGitHub, buildLinux, ... } @ args:

let
  inherit (lib) versions;

  kernelVersion = "6.18.12";
  vendorVersion = "valve1";
  hash = "sha256-eY6GYt5P3MbFP00Qx7iSwX5LAzVu71nfo+JmaZynW6o=";
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
    SND_SOC_NAU8821 = module;
    SND_SOC_MAX98388 = module;

    SND_SOC_AMD_ACP3x = no;
    # Jovian: unused?
    # SND_SOC_AMD_RV_RT5682_MACH = no;
    SND_SOC_AMD_RENOIR = no;
    # Jovian: unused?
    # SND_SOC_AMD_RENOIR_MACH = no;

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

    SND_SOC_SOF = module;
    SND_SOC_SOF_PROBE_WORK_QUEUE = yes;
    SND_SOC_SOF_IPC3 = yes;
    # Jovian: renamed from _INTEL_
    # https://github.com/Jovian-Experiments/linux/commit/e31b20c2f0c2e561e7b1bf671fe38bd5d83a496f
    SND_SOC_SOF_IPC4 = yes;

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

    LENOVO_WMI_GAMEZONE = module;
    LENOVO_WMI_TUNING = module;
    # Jovian: renamed
    # LENOVO_LEGOS_HID = module;
    HID_LENOVO_GO = module;
    HID_LENOVO_GO_S = module;

    ZOTAC_ZONE_HID = module;
    ZOTAC_ZONE_PLATFORM = module;

    HID_ASUS_ALLY = module;
    ASUS_ARMOURY = module;
    ASUS_WMI_DEPRECATED_ATTRS = yes;

    # PARAVIRT options have overhead, even on bare metal boots. They can cause
    # spinlocks to not be inlined as well. Either way, we don't intend to run this
    # kernel as a guest, so this also clears out a whole bunch of
    # virtualization-specific drivers.
    HYPERVISOR_GUEST = lib.mkForce no;

    # Disable some options enabled in ArchLinux 6.1.12-arch1 config
    # Jovian: we do have Rust, and we can't lie about it
    # HAVE_RUST = no;
  
    # This has been disabled upstream since 6.11.8-arch1
    # See: https://gitlab.archlinux.org/archlinux/packaging/packages/linux/-/commit/1a06ca984333093fb12cbbff275da31fa2bc5f6c
    ZSWAP_DEFAULT_ON = yes;

    # Build as module to experiment with toggling
    # Jovian: NixOS pulls it in as y always
    # TCG_TPM = module;

    # Per Colin at Quectel
    CFG80211_CERTIFICATION_ONUS = yes;
    ATH_REG_DYNAMIC_USER_REG_HINTS = yes;

    # Enable ath11k tracing for wifi debugging
    ATH11K_TRACING = yes;

    # Disable simple-framebuffer to fix logo regression
    SYSFB_SIMPLEFB = lib.mkForce no;
    DRM_EFIDRM = no;
    DRM_VESADRM = no;

    # Enable Extensible Scheduling Class
    SCHED_CLASS_EXT = yes;

    # Disable call depth tracking speculative execution vulnerability mitigation
    # Jovian: renamed
    MITIGATION_CALL_DEPTH_TRACKING = no;

    # Disable drm panic screen
    DRM_PANIC = lib.mkForce no;

    # Xbox GIP driver
    JOYSTICK_XBOX_GIP = module;
    JOYSTICK_XBOX_GIP_FF = yes;
    JOYSTICK_XBOX_GIP_LEDS = yes;

    # Enable Valve LEDs driver
    LEDS_VALVE = module;

    # Jovian: fix fallout from the vendor-set options
    DRM_AMD_DC_SI = lib.mkForce (option no);
    DRM_HYPERV = lib.mkForce (option no);
    DRM_PANIC_SCREEN = lib.mkForce (option no);
    DRM_PANIC_SCREEN_QR_CODE = lib.mkForce (option no);
    FB_HYPERV = lib.mkForce (option no);
    HYPERV = lib.mkForce (option no);
    INTEL_TDX_GUEST = lib.mkForce (option no);
    KVM_GUEST = lib.mkForce (option no);
    MOUSE_PS2_VMMOUSE = lib.mkForce (option no);
    NOVA_CORE = lib.mkForce (option no);
    PARAVIRT_TIME_ACCOUNTING = lib.mkForce (option no);
    TDX_GUEST_DRIVER = lib.mkForce (option no);
  };

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux";
    rev = version;
    inherit hash;

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
