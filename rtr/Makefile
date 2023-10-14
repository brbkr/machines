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
# Setting up the EFI System Partition (ESP):
# https://0pointer.net/blog/linux-boot-partitions.html
#
# Future:
# - ZFS
#
# 10GB /boot	vfat (ESP)
# 10GB /	ext4
# 10GB /tmp	ext4
# 10GB /var	ext4
# 10GB /var/tmp	ext4
# 10GB /var/log	ext4
# 200GB /nix	ext4
# 220GB /home	ext4

# systemd-gpt-auto-generator:
# https://0pointer.net/blog/linux-boot-partitions.html
# https://uapi-group.org/specifications/specs/discoverable_partitions_specification/
# https://man7.org/linux/man-pages/man8/systemd-gpt-auto-generator.8.html
#
SD_GPT_ROOT_X86_64=4f68bce3-e8cd-4db1-96e7-fbcaf984b709	# /
SD_GPT_HOME=933ac7e1-2eb4-4f13-b844-0e14e2aef915	# /home
SD_GPT_VAR=4d21b016-b534-45c2-a9fb-5c16e091fd2d		# /var
SD_GPT_TMP=7ec6f557-3bc5-4aca-b293-16ef5df639d1		# /var/tmp
SD_GPT_SWAP=0657fd6d-a4ab-43c4-84e5-0933c84b4f4f
SD_GPT_ESP=c12a7328-f81f-11d2-ba4b-00a0c93ec93b		# /boot (ESP)

.PHONY: install
install:	## ssh, partition, and install; requires ssh root@$(NIXADDR)
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		set -x; \
		newhostname=$(subst /,,$(dir $@)); \
		while grep -q /dev/nvme0n1 /etc/mtab; do awk '/dev\/nvme0n1/ {system(\"umount \" \$$1)}' /etc/mtab; done; \
		sfdisk --delete /dev/nvme0n1; \
		parted -s /dev/nvme0n1 -- \
			mklabel gpt \
			mkpart primary 512MB 5GB \
			mkpart extended 5GB 15GB \
			mkpart extended 15GB 25GB \
			mkpart extended 25GB 35GB \
			mkpart extended 35GB 45GB \
			mkpart extended 45GB 55GB \
			mkpart extended 55GB 275GB \
			mkpart extended 275GB -16GB \
			mkpart extended linux-swap -16GB 100\% \
			set 1 esp on; \
		sleep 1; \
		yes | mkfs.fat -F 32 -n ESP /dev/nvme0n1p1; \
		yes | mkfs.ext4 -q -L root -U $(SD_GPT_ROOT_X86_64) /dev/nvme0n1p2; \
		yes | mkfs.ext4 -q -L tmp /dev/nvme0n1p3; \
		yes | mkfs.ext4 -q -L var -U $(SD_GPT_VAR) /dev/nvme0n1p4; \
		yes | mkfs.ext4 -q -L var-tmp -U $(SD_GPT_TMP) /dev/nvme0n1p5; \
		yes | mkfs.ext4 -q -L var-log /dev/nvme0n1p6; \
		yes | mkfs.ext4 -q -L nix /dev/nvme0n1p7; \
		yes | mkfs.ext4 -q -L home -U $(SD_GPT_HOME) /dev/nvme0n1p8; \
		yes | mkswap -q -L swap -U $(SD_GPT_SWAP) /dev/nvme0n1p9; \
		sleep 1; \
		mount /dev/disk/by-label/root /mnt; \
		mkdir -p /mnt/boot; \
		mkdir -p /mnt/tmp; \
		mkdir -p /mnt/var; \
		mkdir -p /mnt/nix; \
		mkdir -p /mnt/home; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/ESP /mnt/boot; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/tmp /mnt/tmp; \
		mount -o nodev,nosuid,noexec /dev/disk/by-label/var /mnt/var; \
		mkdir -p /mnt/var/tmp; \
		mkdir -p /mnt/var/log; \
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

.PHONY: bootstrap
bootstrap:	## Initial configuration, run only immediately after install
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='.git/' \
		$(CURDIR)/nixos/ root@$(NIXADDR):/etc/nixos/
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		nixos-rebuild switch \
	"

.PHONY: push
push:	## Copy NIX and SSH configuration to a bootstrapped machine
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='.git/' \
		--rsync-path="sudo rsync" \
		$(CURDIR)/ $(NIXUSER)@$(NIXADDR):/etc/nixos

	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

.PHONY: test
test:	## Run nixos-rebuild test
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo nixos-rebuild test \
	"

.PHONY: switch
switch:	## Run nixos-rebuild switch
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo nixos-rebuild switch \
	"
