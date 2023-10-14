# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

# coredns
# hosts plugin: https://coredns.io/plugins/hosts/
#   - ../../mdlayher/homelab/nixos/routnerr-3/coredns.nix
#   - He has a go program write a JSON file that gets parsed
#   - For my purposes, coredns is fine, but the hosts plugin with a static hosts file is easier
#   - This means ./coredns/hosts
#   - When we add the next server, we have to find a way to keep the IPs in sync

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./pkgs.nix
      ./users.nix
      ./services.nix
      ./system.nix
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

