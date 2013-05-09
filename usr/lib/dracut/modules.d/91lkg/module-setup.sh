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
	dracut_install -o getfacl
	dracut_install -o setfacl
	dracut_install -o getfattr
	dracut_install -o setfattr
	inst grep
	inst rsync
	inst sort
	inst xargs
	inst lvm
	inst lvs
	inst lvcreate
	inst lvremove
	inst lvchange

	# We want to be able to parse the kernel command
	# line so we register a hook for it.
	inst_hook cmdline 90 "$moddir/lkg_cmd_parse.sh"

	# The 65-lkg.rules file installs UDEV rules to call
	# lkg_scan.sh after block devices (and LVM) should
	# have settled.  lkg_scan.sh uses lkg_mkln.sh to 
	# create symbolic links to @lkg_source volumes.
	inst_script "$moddir/lkg_mkln.sh" /sbin/lkg_mkln.sh
	inst_script "$moddir/lkg_scan.sh" /sbin/lkg_scan.sh
	inst_rules "$moddir/65-lkg.rules"

	# The lkg_candidate.sh script uses lkg_mk_snaplv.sh
	# to create LKG candidate snapshots UNLESS we are
	# booting from an LKG snapshot.
	inst_script "$moddir/lkg_mk_snap_lv.sh" /sbin/lkg_mk_snap_lv.sh
	inst_hook pre-mount 99 "$moddir/lkg_candidate.sh"
	
	# The lkg_snapselect.sh script uses lkg_mk_copy_lv.sh
	# to create LKG active snapshots ONLY when we are
	# booting from an LKG snapshot.
	inst_script "$moddir/lkg_mk_copy_lv.sh" /sbin/lkg_mk_copy_lv.sh
	inst_hook pre-mount 99 "$moddir/lkg_snapselect.sh"
}