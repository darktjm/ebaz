#!/bin/sh

set -e

BOARD_DIR="$(dirname $0)"

if ! grep -qE '^kvm' "${TARGET_DIR}/etc/group"; then
	echo "Adding kvm group"
	echo "kvm:x:78:" >> "${TARGET_DIR}/etc/group"
fi

#cp -fv ${BOARD_DIR}/boot.bin ${BINARIES_DIR}/boot.bin
#if [ -e ${BINARIES_DIR}/boot.scr ]; then
#	cp -fv ${BINARIES_DIR}/boot.scr ${TARGET_DIR}/boot/boot.scr
#fi
printenv >/tmp/env
echo "Generate boot.bin for flashing or SD card"
# Note: uses fsbl binary etracted from flash; using embeddedsw to build one
# has not produced a working one yet.
# 1700 and 6004 came from the bootgen header
#   dd if=/dev/mtdblock0 of=fsbl.bin bs=1 skip=$((0x1700)) count=$((0x6004*4))
# Note: uses pre-generated bitstream, as ensuring that you can actually
# built it is too much trouble for me right now.
# Stupid bootgen only sets fsbl length if it reads from elf
arm-linux-objcopy -I binary -Oelf32-littlearm ${BOARD_DIR}/fsbl.bin ${BINARIES_DIR}/fsbl.o || exit 1
arm-linux-ld -o ${BINARIES_DIR}/fsbl.elf ${BINARIES_DIR}/fsbl.o || exit 1
(cd ${BINARIES_DIR}; bootgen -arch zynq -image ../../${BOARD_DIR}/boot.bif -w on -o boot.bin) || exit 1

# Add a console on tty1
#if [ -e ${TARGET_DIR}/etc/inittab ]; then
#    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
#	sed -i '/GENERIC_SERIAL/a\
#tty1::respawn:/sbin/getty -L  tty1 0 linux # HDMI console' ${TARGET_DIR}/etc/inittab
#fi

# Fix audispd path error
if [ -e ${TARGET_DIR}/etc/audit/auditd.conf ]; then
	echo "Fix audispd path in auditd.conf"
	sed -e 's%dispatcher = .*%dispatcher = /usr/sbin/audispd%' -i ${TARGET_DIR}/etc/audit/auditd.conf
fi

# Fix auditd init script
if [ -e ${TARGET_DIR}/etc/init.d/S02auditd ]; then
	echo "Fix auditd init script"
	cp -fv ${BOARD_DIR}/S02auditd ${TARGET_DIR}/etc/init.d/S02auditd
fi

# Fix restorecond init script
if [ -e ${TARGET_DIR}/etc/init.d/S20restorecond ]; then
	echo "Fix restorecond init script"
	cp -fv ${BOARD_DIR}/S20restorecond ${TARGET_DIR}/etc/init.d/S20restorecond
fi

for arg in "$@"
do
	case "${arg}" in
		--enable-openssh-root)
			if [ -e ${TARGET_DIR}/etc/ssh/sshd_config ]; then
				echo "Enable openssh root login"
				sed -e "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/" -i "${TARGET_DIR}/etc/ssh/sshd_config"
			fi
			;;

		--add-openssh-keys)
			if [ -d ${TARGET_DIR}/etc/ssh ]; then
				if [ ! -f ${TARGET_DIR}/etc/ssh/ssh_host_rsa_key ]; then
					echo "Generate openssh rsa host key for target"
					ssh-keygen -f ${TARGET_DIR}/etc/ssh/ssh_host_rsa_key -N '' -t rsa
				fi
				if [ ! -f ${TARGET_DIR}/etc/ssh/ssh_host_dsa_key ]; then
					echo "Generate openssh dsa host key for target"
					ssh-keygen -f ${TARGET_DIR}/etc/ssh/ssh_host_dsa_key -N '' -t dsa
				fi
				if [ ! -f ${TARGET_DIR}/etc/ssh/ssh_host_ed25519_key ]; then
					echo "Generate openssh ed25519 host key for target"
					ssh-keygen -f ${TARGET_DIR}/etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
				fi
				if [ ! -f ${TARGET_DIR}/etc/ssh/ssh_host_ecdsa_key ]; then
					echo "Generate openssh ecdsa host key for target"
					ssh-keygen -f ${TARGET_DIR}/etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
				fi
			fi
			;;
	esac
done

exit $?
