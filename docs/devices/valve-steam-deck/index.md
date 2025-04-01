Steam Deck
==========

Configuration
-------------

When configuring the system, import `./modules` from this repo in your configuration and enable the Steam Deck-specific hardware configurations with `jovian.devices.steamdeck.enable = true;`.


Firmware Updates
----------------

Firmware update, at this time, is not handled automatically.

### `steamdeck-firmware`

Updates to the BIOS and the controller are available in the `steamdeck-firmware` package:

- BIOS: Run `sudo jupiter-biosupdate`
- Controller: Run `sudo jupiter-controller-update`

### `jupiter-dock-updater-bin`

Updates to the Docking Station firmware are available in the `jupiter-dock-updater-bin` package.
Connect to the dock via USB-C and run `jupiter-dock-updater` to update.


Helpful Tips
------------

To enter the boot menu, power off the Steam Deck then hold down `Volume Down` and tap the `Power` button.
