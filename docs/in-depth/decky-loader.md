Decky Loader
============

To enable *Decky Loader* in your configuration:

```nix
{
  jovian.decky-loader = {
    enable = true;
  };
}
```

### Setup

After having switched to your new configuration with Decky enabled, open Steam, navigate to
**Settings > Developer** and activate the `CEF Remote Debugging` setting. This is required for
Decky to inject its UI components.

After enabling the option, you must log out or reboot for the change to take effect.
> Note: The "Restart Steam" option in the power menu will not work!
