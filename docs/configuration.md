Configuration
=============

> [!INFO]
> This page is a stub.

All available module options along with their descriptions can be found under `modules`.

To use the Steam Deck UI, set `jovian.steam.enable = true;` in your configuration.
This will only enable the Steam Deck UI tooling. To enable "desktop" steam, enable the usual NixOS options.
Then you can start the UI using one of the following methods:

- (**preferred**) Use `jovian.steam.autoStart = true;` to auto-start at login, and enabling use of *Switch to Desktop* option.
- Select "Gaming Mode" in the Display Manager or run `start-gamescope-session` in a VT.
- Launch `gamescope-session` within an existing desktop session. This will run [gamescope](https://github.com/Plagman/gamescope) in nested mode which results in higher latency.

If you want *Switch to Desktop* to switch to another session with `autoStart`, you will need to configure `jovian.steam.desktopSession`.
Configure it with the name of the X11 or Wayland session of your choosing.
The *Switch to Desktop* option will not work with the other two methods of running the Steam Deck UI, instead it will close Steam.

