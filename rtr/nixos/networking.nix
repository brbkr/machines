# References

# NixOS documentation
# https://nixos.org/manual/nixos/stable/#sec-networking
# https://nixos.wiki/wiki/Networking
# https://nixos.wiki/wiki/Systemd-networkd

# Rename networks
# https://nixos.org/manual/nixos/stable/#sec-custom-ifnames
# https://superuser.com/questions/914646/renaming-network-interface-with-systemd

# This is the path to the implementation of the systemd module in nixos
# /nix/store/7a5d615xfkkyqmnlymb1ak34qzi8iy6s-nixos-23.05/nixos/nixos/modules/system/boot/networkd.nix
#
# Options are extracted and documented here:
# https://nixos.org/manual/nixos/stable/options

# This file defines a
# https://unix.stackexchange.com/questions/272660/how-to-split-etc-nixos-configuration-nix-into-separate-modules

# Debugging
#   [jtb@nixos:~]$ sudo SYSTEMD_LOG_LEVEL=debug udevadm test-builtin net_setup_link /sys/class/net/enp1s0
#   Trying to open "/etc/udev/hwdb.bin"...
#   === trie on-disk ===
#   tool version:          253
#   file size:        11993573 bytes
#   header size             80 bytes
#   strings            2530437 bytes
#   nodes              9463056 bytes
#   Loading kernel module index.
#   Found cgroup2 on /sys/fs/cgroup/, full unified hierarchy
#   Found container virtualization none.
#   Using default interface naming scheme 'v253'.
#   Parsed configuration file "/nix/store/12bynbp6y51j5449l27sy8ycgksd8npk-systemd-253.6/lib/systemd/network/99-default.link"
#   Parsed configuration file "/etc/systemd/network/11-lan1.link"
#   Parsed configuration file "/etc/systemd/network/10-lan0.link"
#   Created link configuration context.
#   enp1s0: Device has name_assign_type=4
#   enp1s0: Device has addr_assign_type=0
#   ID_NET_DRIVER=igc
#   enp1s0: Config file /etc/systemd/network/10-lan0.link is applied
#   enp1s0: Using static MAC address.
#   enp1s0: Policies didn't yield a name, using specified Name=lan0.
#   ID_NET_LINK_FILE=/etc/systemd/network/10-lan0.link
#   ID_NET_NAME=lan0
#   ID_NET_LINK_FILE_DROPINS=
#   Unload kernel module index.
#   Unloaded link configuration context.


{ ... }:
{
  networking = {
    hostName = "rtr";
    useNetworkd = true;
    usePredictableInterfaceNames = false;
  };

  services.resolved = {
    enable = true;
    domains = [ "bruli.us" "tailcd6af.ts.net" ];
  };

  systemd.network = {
    enable = true;

    links."10-lan0" = {
      matchConfig.PermanentMACAddress = "7c:83:34:bc:8b:8f";
      linkConfig.Name = "lan0";
    };

    links."11-lan1" = {
      matchConfig.PermanentMACAddress = "7c:83:34:bc:8b:90";
      linkConfig.Name = "lan1";
    };

    # Tailscale interface doesn't indicate whether the machine is online
    wait-online.ignoredInterfaces = [ "ts0" ];
    wait-online.enable = false;
  };

  # Tailscale readiness from mdlayher; unsure if required.
  systemd.services.tailscaled.after =
    [ "network-online.target" "systemd-resolved.service" ];
}
