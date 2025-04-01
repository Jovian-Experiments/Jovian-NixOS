Decky Loader
============

> [!INFO]
> This page is a stub.

To enable *Decky Loader* in your configuration:

```nix
{
  jovian.decky-loader = {
    enable = true;
  };
}
```


## It doesn't work

There is a known issue where Decky Loader relies on CEF debugging to work, but enabling/disabling it *correctly* is awkward.

See [the workaround in #460](https://github.com/Jovian-Experiments/Jovian-NixOS/issues/460#issuecomment-2599835660).

Make sure you also enable CEF debugging imperatively.
