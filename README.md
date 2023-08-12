<div align="center"><h1>Jovian NixOS</h1></div>
<div align="center"><strong><em>NixOS on the Steam Deck</em></strong></div>

****

A set of packages and configurations for running NixOS on the [Steam Deck](https://www.steamdeck.com).
This repo is also useful for obtaining a Deck-like experience on other `x86_64` devices.

Installation
------------

Use [the normal installation images](https://nixos.org/download.html#download-nixos) available on NixOS.org.

Prefer the `nixos-unstable` image, but you can also use the latest stable image as long as you use the `unstable` channel for the system.

When configuring the system, import `./modules` from this repo in your configuration.

### Steam Deck

To enter the boot menu, power off the Steam Deck then hold down `Volume-` and tap the `Power` button.

When configuring the system, import `./modules` from this repo in your configuration and enable the Steam Deck-specific hardware configurations with `jovian.devices.steamdeck.enable = true;`.

### Other Devices

No other device-specific quirks or configuration handled for now.

Feel free to contribute one or more!

Configuration
-------------

All available module options along with their descriptions can be found under `modules`.

To use the Steam Deck UI, set `jovian.steam.enable = true;` in your configuration.
This will only enable the Steam Deck UI tooling. To enable "desktop" steam, enable the usual NixOS options.
Then you can start the UI using one of the following methods:

- (**preferred**) Use `jovian.steam.autoStart = true;` to auto-start at login, and enabling use of *Switch to Desktop* option.
- Select "Gaming Mode" in the Display Manager or run `steam-session` in a VT.
- Launch `steam-session` within an existing desktop session. This will run [gamescope](https://github.com/Plagman/gamescope) in nested mode which results in higher latency.

If you want *Switch to Desktop* to switch to another session with `autoStart`, you will need to configure `jovian.steam.desktopSession`.
Configure it with the name of the X11 or wayland session of your choosing.
The *Switch to Desktop* option will not work with the other two methods of running the Steam Deck UI, instead if will close Steam.

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

> What channels are supported?

Truthfully, no channel is *supported*, but the older the stable release was cut, the more likely the additions from Jovian NixOS won't work as expected.

Thus, it is preferrable to use `nixos-unstable`. The latest update *should* work fine, and when it doesn't, it'll be handled soon enough.

* * *

Importing the modules in your configuration
-------------------------------------------

One way to do so is by using `fetchTarball` in the `imports` of your configuration.

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    (
      # Put the most recent revision here:
      let revision = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; in
      builtins.fetchTarball {
        url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
        # Update the hash as needed:
        sha256 = "sha256:0000000000000000000000000000000000000000000000000000";
      } + "/modules"
    )

  /* ... */
  ];

  /* ... */
}
```

Another way is to use *Flakes*, or any other method to fetch inputs.

When hacking on Jovian NixOS things, adding the path to a Git checkout of this repo to `imports` works well too.
