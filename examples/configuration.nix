# Example configuration of the Jovian NixOS flavor for Steam Deck

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include Jovian NixOS Modules - Must be cloned manually!
      /src/Jovian-NixOS/modules
    ];

  # Set your time zone.
  time.timeZone = "Europe/UTC";

  # Set System Name
  networking.hostName = "steamdeck";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";
  
  # Enable Jovian NixOS additions
  jovian = {
    # Include hardware configuration
    devices.steamdeck.enable = true;
    # Add Steam additions
    steam.enable = true;
  }

  # Allow Unfree Packages
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # DisplayManager
  ## SDDM and GDM are recommended as they provide usable virtual keyboard
  services.xserver.displayManager.sddm.enable = true;

  #services.xserver.displayManager.gdm.enable = true;

  # Desktop Environment ("DE")
  ## GNOME, KDE, Plasma Mobile are recommended as they play well with Steam Deck, but you can also just use the deck without DE

  # GNOME
  #services.xserver.desktopManager.gnome.enable = true;
 
  # KDE
  #services.xserver.desktopManager.plasma5.enable = true;

  # Plasma Mobile
  services.xserver.desktopManager.plasma5.mobile.enable = true;

  # Install steam system-wide
  programs.steam = {
    enable = true;
    # To add firewall rules for remotePlay to work
    remotePlay.openFirewall = true;
  }

  # User Management
  users.users = {
    steamuser = {
      isNormalUser = true;
      initialPassword = "steam"; # Default Password
      extraGroups = [ "wheel" "networkmanager" ];
      # To enable OpenSSH
      #openssh.authorizedKeys.keys = [
      #  "content of ~/.ssh/id_yourkey.pub here"
      #];
    };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Tor
  services.tor = {
    enable = true;
    client.enable = true;
    # This will provide a file `/var/lib/tor/onions/hiddenSSH/hostname` containing an onion-url which you can then connect to using `ssh YOUR-USER@ONION-URL` as long as the device is connected to the internet
    relay.onionServices."hiddenSSH".map = [ 22 ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Garbage collection every week for derivations older than 7d
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable autoUpgrades
  system.autoUpgrade = {
    enable = true;
    # This will allow immediate reboot after the automatic system upgrade is completed e.g. in kernel updates
    allowReboot = true;
  };

  # Optimization - Prefer to use non-swap storage for data -> Faster loading
  boot.kernel.sysctl = { "vm.swappiness" = 10;};

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It’s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
