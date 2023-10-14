{
  # Services which run on all deployed machines.
  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "ethtool" "systemd" ];
    };
  };
}
