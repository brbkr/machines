# rtr Makefile

# Target machine information
NIXADDR ?= 10.0.0.43
NIXPORT ?= 22
NIXUSER ?= jtb

# SSH options that are used during installation
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# Partition layout derived from the Practical Linux Hardening Guide:
# https://github.com/trimstray/the-practical-linux-hardening-guide/wiki/Bootloader-and-Partitions
#
# 10GB /boot	ext4
# 10GB /	ext4
# 10GB /tmp	ext4
# 10GB /var	ext4
# 10GB /var/tmp	ext4
# 10GB /var/log	ext4
# 200GB /nix	ext4
# 220GB /home	ext4
#
# Future:
# - ZFS
#
.PHONY: install
install:	## ssh, partition, and install; requires ssh root@$(NIXADDR)
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		newhost=$(subst /,,$(dir $@)); \
		mount | grep /dev/nvme0n1 | awk '{print $1}' | xargs -rn1 umount; \
		sfdisk --delete /dev/nvme0n1; \
		yes | parted /dev/nvme0n1 -- mklabel gpt; \
		yes | parted /dev/nvme0n1 -- mkpart primary 512MB 10GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended 10GB 20GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended 20GB 30GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended 30GB 40GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended 40GB 50GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended 50GB 60GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended 60GB 275GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended 275GB -16GB; \
		yes | parted /dev/nvme0n1 -- mkpart extended linux-swap -16GB 100\%; \
		yes | parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB; \
		yes | parted /dev/nvme0n1 -- set 10 esp on; \
		sleep 1; \
		yes | mkfs.ext4 -L boot /dev/nvme0n1p1; \
		yes | mkfs.ext4 -L root /dev/nvme0n1p2; \
		yes | mkfs.ext4 -L tmp /dev/nvme0n1p3; \
		yes | mkfs.ext4 -L var /dev/nvme0n1p4; \
		yes | mkfs.ext4 -L var-tmp /dev/nvme0n1p5; \
		yes | mkfs.ext4 -L var-log /dev/nvme0n1p6; \
		yes | mkfs.ext4 -L nix /dev/nvme0n1p7; \
		yes | mkfs.ext4 -L home /dev/nvme0n1p8; \
		yes | mkswap -L swap /dev/nvme0n1p9; \
		yes | mkfs.fat -F 32 -n EFI /dev/nvme0n1p10; \
		sleep 1; \
		mount /dev/disk/by-label/root /mnt; \
		mkdir -p /mnt/boot; \
		mkdir -p /mnt/tmp; \
		mkdir -p /mnt/var/tmp; \
		mkdir -p /mnt/var/log; \
		mkdir -p /mnt/nix; \
		mkdir -p /mnt/home; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/boot /mnt/boot; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/tmp /mnt/tmp; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/var /mnt/var; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/var-tmp /mnt/var/tmp; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/var-log /mnt/var/log; \
		mount -o noatime /dev/disk/by-label/nix /mnt/nix; \
		mount -o noatime,nodev /dev/disk/by-label/home /mnt/home; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
  			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

