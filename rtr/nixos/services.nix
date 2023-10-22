{ ... }:
{
  services = {
    fstrim.enable = true;
    fwupd.enable = true;

    # https://nixos.wiki/wiki/SSH_public_key_authentication
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    # https://nixos.wiki/wiki/Tailscale
    tailscale = {
      enable = true;
      interfaceName = "ts0";
      permitCertUid = "caddy";
      useRoutingFeatures = "server";
    };
  };
}
