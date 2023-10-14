{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Locale and time.
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  # Enable firmware updates when possible.
  hardware.enableRedistributableFirmware = true;

  system.autoUpgrade.enable = true;

  # Make systemd manage the hardware watchdog.
  systemd.watchdog.runtimeTime = "60s";

  # Console configuration.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
