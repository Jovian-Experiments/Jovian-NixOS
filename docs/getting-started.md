Getting Started
===============

Using Jovian NixOS requires *some* NixOS knowledge, ideally.
It's not a strict requirement, but will make your life easier, as this may make some NixOS peculiarities harder to deal with.


Installing NixOS
----------------

For now, this may be the "hardest" step, as it requires thinking ahead.
Note that you're free to install NixOS in any way you want.

Though here are the requirements:

 - Only the `unstable` channel is supported.

Here are some tips:

 - You will most likely need some way to type commands, e.g. a keyboard.
 - You can use an SD card to boot the installation media, freeing-up the only USB port.
 - Using a docking station sure is helpful, but not needed.
 - FDE (full-disk encryption) may or may not be an issue, considering there is no physical keyboard.

Up to this moment, nothing here is specific to Jovian NixOS or the Steam Deck.


Configuring Jovian NixOS
------------------------

This is where the fun begins!


### Configuring for your hardware

This only applies if you have a "made for gaming" device like the Steam Deck, or other portable gaming devices.

Other computers are just boring computers, and mostly need nothing special here.
Note that since the Steam Deck experience is developed on AMD hardware, using [other hardware](https://github.com/Jovian-Experiments/Jovian-NixOS/labels/8.%20hardware%3A%20other) may have issues, especially [NVIDIA hardware](https://github.com/Jovian-Experiments/Jovian-NixOS/labels/8. hardware%3A NVIDIA).

**Known hardware**

 - [Valve Steam Deck](devices/valve-steam-deck/index.md)

Feel free to contribute more for-gaming hardware-specific quirks!


### Configuring the software

> [!INFO]
> This section is a stub.

When configuring the system, import `./modules` from this repo in your configuration.

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

See the [Configuration](configuration.md) page for more information about configuration.
