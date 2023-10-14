let
	secrets = import ./secrets.nix;
in
{
  # Put ~/bin in PATH.
  environment.homeBinInPath = true;

  users = {
    # Force declarative user configuration.
    mutableUsers = false;

    # jtb - groups: sudo, ssh
    users.jtb = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "dialout" "libvirtd" "networkmanager" "wheel" ];
      hashedPassword = secrets.passwords.jtb;

      openssh.authorizedKeys.keys = [
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEXNGVTm+cH2Yw5BAftRVoEkbdshp7fen4elfm8R066 Jeff Brubaker <jeff.brubaker@gmail.com>"
      ];
    };

    # Set up root login for emergency console access.
    users.root.hashedPassword = secrets.passwords.root;
  };
}
