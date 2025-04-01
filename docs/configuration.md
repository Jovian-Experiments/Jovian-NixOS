Configuration
=============

## Using the Steam Deck UI

To use the Steam Deck UI, set `jovian.steam.enable = true;` in your configuration.

This will only enable the Steam Deck UI tooling.
**To enable "desktop" Steam**, enable the usual NixOS options.

The Steam Deck UI can be used in different manners.

### Autostart

(*This is the preferred way to use the Steam Deck interface*)

Set `jovian.steam.autoStart = true;` to auto-start at boot.

This also enables use of the *Switch to Desktop* option.

> [!NOTE]
> To go back to the *Steam Deck interface* from the *desktop* interface, logout or exit from your desktop environment.

If you want the *Switch to Desktop* menu option to switch to another session, you will need to configure `jovian.steam.desktopSession`.
Configure it with the name of the X11 or Wayland session of your choosing.
The session name semantics are the same as for the `services.displayManager.defaultSession` NixOS option.

### As a user session

Select the *Gaming Mode* sesssion in your Display Manager, or run `start-gamescope-session` in a VT.

The *Switch to Desktop* option will not work as intended, instead it will close Steam.


### As a *nested* window

Run `gamescope-session` within an existing desktop session.

This will run [gamescope](https://github.com/ValveSoftware/gamescope) in nested mode which may result in higher latency.

Usage as a *nested* window is less tested, and may have other undesirable idiosyncrasies.

The *Switch to Desktop* option will not work as intended, instead it will close Steam.


## Going further

This is a NixOS system, you can do much more.
[All the usual NixOS options are available](https://search.nixos.org/options?channel=unstable).

In addition to that, all the Jovian NixOS options, including internal implementation details,
are listed on the [options page in the documentation](https://jovian-experiments.github.io/Jovian-NixOS/options.html).
