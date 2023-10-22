# References

# NixOS documentation
# https://nixos.org/manual/nixos/stable/#sec-networking
# https://nixos.wiki/wiki/Networking

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

{ ... }:
{
  networking = {
    hostName = "rtr";
    useNetworkd = true;
  };

  services.resolved = {
    enable = true;
    domains = [ "bruli.us" "tailcd6af.ts.net" ];
  };

  systemd.network = {
    enable = true;

    links."10-lan0" = {
      matchConfig = {
	Type = "ether";
	MACAddress = "7c:83:34:bc:8b:8f";
      };
      linkConfig = {
	Name = "lan0";

	RxBufferSize = 4096;
	TxBufferSize = 4096;
      };
    };

    links."20-lan1" = {
      matchConfig = {
	Type = "ether";
	MACAddress = "7c:83:34:bc:8b:90";
      };
      linkConfig = {
	Name = "lan1";

	RxBufferSize = 4096;
	TxBufferSize = 4096;
      };
    };

    # Tailscale interface doesn't indicate whether the machine is online
    wait-online.ignoredInterfaces = [ "ts0" ];
  };

  # Tailscale readiness from mdlayher; unsure if required.
  systemd.services.tailscaled.after =
    [ "network-online.target" "systemd-resolved.service" ];
}
