Jovian NixOS modules organization
=================================

## `devices/`

Device-specific options.

New devices should have their namespace (folder and options) prefixed by the vendor name.

Only options specific to the devices should be *defined* there.


## `hardware/`

Hardware-specific options.

These options are assumed correct for a larger scope of devices.

Hardware options should be gated behind `hardware.has.*` options.


## `steam/`

Steam-specific options.

These options control and affect use of the "steam deck mode" steam interface.


## `steamos/`

Options mirroring generic configuration from SteamOS.

Any non-device-specific opinionated configuration should be defined here.


## `jovian/`

Misc. mostly internal options to make Jovian NixOS work.
