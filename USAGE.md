Using Jovian NixOS
==================

> **Note**: You will need to bring your own NixOS configuration to make it
> useful. This only configures defaults to work better with the hardware.

To compose Jovian NixOS into your configuration is as simple as importing the
modules directory into your configuration.

For example, using `builtins.fetchTarball`, in your configuration.nix:

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

This configuration adds some options. For now you will have to look under the
`modules/` directory to know what they are, and what they do.

The defaults should provide a configuration approximating the vendor
configurations.

This means that *simply by adding this to your configuration* should be enough.
