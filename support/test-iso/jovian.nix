{
  imports = [
    ../../modules
  ];

  jovian = {
    devices.steamdeck = {
      enable = true;
    };
    steam = {
      enable = true;
      autoStart = true;
      user = "deck";
    };
  };
  networking.networkmanager.enable = true;
}
