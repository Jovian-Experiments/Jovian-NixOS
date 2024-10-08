Steam
=====


You can enable the Steam Deck version of the Steam client with:

```nix
{
  jovian.steam.enable = true;
}
```

To manually start **Gaming Mode** (also known as the **Steam Deck UI**), there are two options:

- Select "Gaming Mode" in the Display Manager or run `start-gamescope-session` in a VT.
- Launch `gamescope-session` within an existing desktop session. This will run [gamescope](https://github.com/ValveSoftware/gamescope) in nested mode which results in higher latency.

## Start On Boot

The following configuration snippet configures the system to automatically launch Gaming Mode on boot, and enables desktop switching to Plasma 6.

```nix
{
  services.desktopManager.plasma6.enable = true;

  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "yourname";
    desktopSession = "plasma";
  };
}
```

> [!NOTE]
> The session name semantics are the same as for the `services.displayManager.defaultSession` NixOS option.


## Troubleshooting

Logs from Gaming Mode can be obtained with:

```bash
journalctl --user -u gamescope-session
```


## Options

<div class="for-github -unneeded">

> [!NOTE]  
> The options listing is available on the website.

</div>
