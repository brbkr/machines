SHELL=/bin/bash
DEV=/dev/sde

# Atari IMG
ATARI_IMG=hd_intel.img
ATARI_IMG_SIZE=4
ATARI_IMG_END=$(shell expr $(ATARI_IMG_SIZE) \* 1024 \* 1024 \* 1024 - 512)
ATARI_SWAPPED_IMG=hd_atari.img

# Linux shell commands
LOSETUP=/usr/sbin/losetup

.PHONY: all
all: $(ATARI_IMG)	## Alias for 'make img'

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: sd
sd: $(ATARI_SWAPPED_IMG)	## Copy hd_intel.img to /dev/sde; hopefully that's the SD card
	[ -b $(DEV) ] || exit 1
	dd if=$(ATARI_SWAPPED_IMG) of=$(DEV) bs=1M

.PHONY: clean
clean:			## Delete hd_intel.img
	umount mnt/drive1 || true
	umount mnt/drive2 || true
	umount mnt/drive3 || true
	umount mnt/drive4 || true
	rmdir mnt/drive[1234] || true
	$(LOSETUP) -D
	rm -f $(ATARI_IMG)
	rm -f $(ATARI_SWAPPED_IMG)

.PHONY: img
img: $(ATARI_IMG)	## Create hd_intel.img, partition, and install software

HATARI_TOS = hatari/tos404.img
HATARI_SHARE = hatari/partitions
HATARI_ARGS = \
	--machine falcon \
	--tos $(HATARI_TOS) \
	--tos-res ttmed \
	--monitor vga \
	--country us \
	--harddrive $(HATARI_SHARE) \
	--ide-master $(ATARI_SWAPPED_IMG) \
	--memsize 14 \
	--statusbar false \

.PHONY: vm
vm: ## Start hatari VM with hd_atari.img
	hatari $(HATARI_ARGS)

$(ATARI_IMG): Makefile
	[ $$(id -u) -eq 0 ] || exit 1
	$(LOSETUP) -D
	umount mnt/drive1 || true
	umount mnt/drive2 || true
	umount mnt/drive3 || true
	umount mnt/drive4 || true
	truncate -s 8G $@
	parted $@ mktable atari
	parted $@ unit s mkpart primary fat16 2048 63487
	parted $@ unit s mkpart primary fat16 63488 555007
	parted $@ unit s mkpart primary fat16 555008 1046527
	parted $@ unit s mkpart primary ext2 1046528 100%
	mkdir -p mnt/drive1
	dev=`$(LOSETUP) --show --find --offset $$((2048 * 512)) --sizelimit $$((30 * 1024 * 1024)) $@`; \
		mkfs.vfat -A -n boot $$dev; \
		mount -t vfat -o quiet $$dev mnt/drive1
	mkdir -p mnt/drive2
	dev=`$(LOSETUP) --show --find --offset $$((63488 * 512)) --sizelimit $$((240 * 1024 * 1024)) $@`; \
		mkfs.vfat -F 16 -S 4096 -s 2 -n apps $$dev; \
		mount -t vfat -o quiet $$dev mnt/drive2
	mkdir -p mnt/drive3
	dev=`$(LOSETUP) --show --find --offset $$((555008 * 512)) --sizelimit $$((240 * 1024 * 1024)) $@`; \
		mkfs.vfat -F 16 -S 4096 -s 2 -n games $$dev; \
		mount -t vfat -o quiet $$dev mnt/drive3
	mkdir -p mnt/drive4
	dev=`$(LOSETUP) --show --find --offset $$((1046528 * 512)) --sizelimit $$((($(ATARI_IMG_SIZE) * 1024 * 1024 * 1024) - (1046528 * 512))) $@`; \
		mkfs.ext2 -t ext2 -O none -E lazy_itable_init=0 -L data $$dev; \
		mount $$dev mnt/drive4
	(cd src/drive1; tar cf - .) | (cd mnt/drive1; tar xf -)
	mv mnt/drive1/auto mnt/drive1/auto2
	mkdir mnt/drive1/auto
	mv mnt/drive1/auto2/mousebt mnt/drive1/auto
	cp mnt/drive1/auto2/mousebt4.prg mnt/drive1/auto
	cp mnt/drive1/auto2/mint-475.prx mnt/drive1/auto
	cp mnt/drive1/auto2/magxboot.prg mnt/drive1/auto
	cp mnt/drive1/auto2/nvdi.prg mnt/drive1/auto
	rm -rf mnt/drive1/auto2
	cp -a src/drive2/INTERNET/STing/STING126/auto/* mnt/drive1/auto
	cp -a src/drive2/INTERNET/STing/STING126/sting mnt/drive1
	cp -a src/drive2/INTERNET/STing/STING126/cpx/* mnt/drive1/cpx
	cp -a src/drive2/INTERNET/STing/TCP_140/tcp.stx mnt/drive1/sting
	cp -a src/drive2/INTERNET/NetUSBee/etherne/ENEC3.STX mnt/drive1/sting
	cp -a src/drive2/INTERNET/falcdate/mint/auto/falcdate.cfg mnt/drive1/auto
	cp -a src/drive2/INTERNET/falcdate/mint/auto/falcdate.prg mnt/drive1/auto/fdatemnt.pnx
	cp -a src/drive2/INTERNET/falcdate/stik/auto/falcdate.prg mnt/drive1/auto/fdatestg.pnx
	(cd src/drive2; tar cf - .) | (cd mnt/drive2; tar xf -)
	(cd src/drive3; tar cf - .) | (cd mnt/drive3; tar xf -)
	#(cd src/drive4; tar cf - .) | (cd mnt/drive4; tar xf -)
	(cd mnt/drive4; tar xf $(CURDIR)/src/sparemint/rootfs+rpm-3.06.tgz)
	ln -sf /usr/share/zoneinfo/US/Eastern mnt/drive4/etc/localtime
	cp -a src/sparemint/RPMS mnt/drive4
	umount mnt/drive1
	umount mnt/drive2
	umount mnt/drive3
	umount mnt/drive4
	$(LOSETUP) -D
	chown jtb $@

$(ATARI_SWAPPED_IMG): $(ATARI_IMG)
	dd if=$< of=$@ conv=swab
