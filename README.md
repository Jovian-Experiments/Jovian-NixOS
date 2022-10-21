<div align="center"><h1>Jovian NixOS</h1></div>
<div align="center"><strong><em>NixOS on the Steam Deck</em></strong></div>

****

A set of packages and configurations for running NixOS on the [Steam Deck](https://www.steamdeck.com).
This repo is also useful for obtaining a Deck-like experience on other `x86_64` devices.

Installation
------------

### Steam Deck

You can build an installation ISO for the Steam Deck with `nix-build -A <flavor>`, where `<flavor>` is one of the following:

- `isoMinimal`: Minimal non-graphical installation environment
- `isoGnome`: Graphical installation ISO with GNOME
- `isoPlasma`: Graphical installation ISO with KDE

To enter the boot menu, power off the Steam Deck then hold down `Volume-` and tap the `Power` button.

Follow the [Installing NixOS](https://nixos.org/manual/nixos/unstable/index.html#sec-installation) section of the NixOS Manual.
When configuring the system, import `./modules` from this repo in your configuration and enable the Steam Deck-specific hardware configurations with `jovian.devices.steamdeck.enable = true;`.

### Other Devices

For all other devices, use [the normal installation images](https://nixos.org/download.html#download-nixos) available on NixOS.org.

Follow the [Installing NixOS](https://nixos.org/manual/nixos/unstable/index.html#sec-installation) section of the NixOS Manual.
When configuring the system, import `./modules` from this repo in your configuration.

Configuration
-------------

All available module options along with their descriptions can be found under `modules`.

To use the Steam Deck UI, set `jovian.steam.enable = true;` in your configuration.
Then you can start the UI using one of the following methods:

- Select "Gaming Mode" in the Display Manager or run `steam-session` in a VT.
- Launch `steam-session` within an existing desktop session. This will run [gamescope](https://github.com/Plagman/gamescope) in nested mode which results in higher latency.

Firmware Updates
----------------

### `steamdeck-firmware`

Updates to the BIOS and the controller are available in the `steamdeck-firmware` package:

- BIOS: Run `sudo jupiter-biosupdate`
- Controller: Run `sudo jupiter-controller-update`

### `jupiter-dock-updater-bin`

Updates to the Docking Station firmware are available in the `jupiter-dock-updater-bin` package.
Connect to the dock via USB-C and run `jupiter-dock-updater` to update.

FAQs
----

> **Jovian**
> “Relating to [...] Jupiter or the class of [...] which Jupiter belongs.”

> What's Jupiter?

[There's a disambiguation page that won't help you](https://en.wikipedia.org/wiki/Jupiter_(disambiguation)).
I don't know *exactly* what it's the codename for.
It is either the codename for the Steam Deck, or the codename for the new Steam OS for the Steam Deck.
Things get awfully murky when you realize that *Neptune*'s also a thing, and it's unclear really from the outside, and quick searches don't provide *conclusive* evidence.
But to the best of my knowledge, Jupiter is the OS for us.
