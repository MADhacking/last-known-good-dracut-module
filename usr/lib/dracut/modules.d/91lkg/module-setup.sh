#! /bin/bash

check() {
	return 0
}

depends() {
	# List the modules we depend on.
	echo lvm
	return 0
}

install() {
	# Install the following binaries to the initrd.
	inst sort
	inst xargs
	inst lvm
	inst lvs
	inst lvcreate
	inst lvremove
	inst lvchange

	# The 65-lkg.rules file installs UDEV rules to call
	# lkg_scan.sh after block devices (and LVM) should
	# have settled.  lkg_scan.sh uses lkg_mkln.sh to 
	# create symbolic links to @lkg_source volumes.
	inst_script "$moddir/lkg_mkln.sh" /sbin/lkg_mkln.sh
	inst_script "$moddir/lkg_scan.sh" /sbin/lkg_scan.sh
	inst_rules "$moddir/65-lkg.rules"

	# The lkg_candidate.sh script uses lkg_mklv.sh to
	# create LKG candidate snapshots UNLESS we are
	# booting from an LKG snapshot.
	inst_script "$moddir/lkg_mklv.sh" /sbin/lkg_mklv.sh
	inst_hook pre-mount 99 "$moddir/lkg_candidate.sh"
	
	# The lkg_snapselect.sh script uses  ONLY when we
	# are booting from an LKG snapshot.
	inst_hook pre-mount 99 "$moddir/lkg_snapselect.sh"
}