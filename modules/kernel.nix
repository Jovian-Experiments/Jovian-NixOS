{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_jovian;
}
