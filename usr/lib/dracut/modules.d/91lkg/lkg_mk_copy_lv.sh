#! /bin/sh

# $1 vg_name
# $2 lv_name
# $3 origin 
# $4 origin_size

. /lib/dracut-lib.sh

info "    duplicating ${1}/${2} to ${1}/${3}_lkgc_active"

safe_mount()
{
	# $1 device
	# $2 mount point
	# $3 options

	# If anything so far has failed then there is no point continuing.
	[ -f /tmp/.lkgstate/failed ] && retuen 1
			
	# Ensure the mount point exists.
	mkdir -p "${2}"
	
	# Try to mount without barriers first, then try with.
	mount -t auto -o barrier=0,${3} "${1}" "${2}" && return 0
	mount -t auto -o ${3}	 		"${1}" "${2}" && return 0
	
	# If we got this far then we failed.
	echo > /tmp/.lkgstate/failed
	return 1
}

test_xattr()
{
	# Check that the getfattr and setfattr commands exist.
	# If they don't then we probably either can't support
	# xattr or we don't care about it.
	command -v getfattr >/dev/null || return 1
	command -v setfattr >/dev/null || return 1
	
	# Check if rsync supports xattr.  If it doesn't then
	# we can't support xattr even if we wanted to.
	rsync -X 2>&1 | grep "rsync: extended" > /dev/null && return 1
	
	# Test for xattr support in the filesystem at $1.
	rv=0
	rdir=${CWD}
	cd ${1}
	TESTFILE="xattr.test"
	echo > ${TESTFILE}
	setfattr -n user.text -v "test1" ${TESTFILE}
	getfattr -d ${TESTFILE} | grep "user.text" | grep -q "test1" >/dev/null || rv=1
	rm ${TESTFILE}
	cd ${rdir}

	return ${rv}
}

test_acl()
{
	# Check that the getfacl and setfacl commands exist.
	# If they don't then we probably either can't support
	# ACLs or we don't care about them.
	command -v getfacl >/dev/null || return 1
	command -v setfacl >/dev/null || return 1
	
	# Check if rsync supports ACLs.  If it doesn't then
	# we can't support ACLs even if we wanted to.
	rsync -A 2>&1 | grep "rsync: ACL" > /dev/null && return 1
	
	# Test for ACL support in the filesystem at $1.
	rv=0
	rdir=${CWD}
	cd ${1}
	TESTFILE="xattr.test"
	echo > ${TESTFILE}
	setfacl --modify=user:root:rw ${TESTFILE} || rv=1
	getfacl ${TESTFILE} | grep -q "user:root:rw" >/dev/null || rv=1
	rm ${TESTFILE}
	cd ${rdir}

	return ${rv}
}

safe_rsync()
{
	# If anything so far has failed then there is no point continuing.
	[ -f /tmp/.lkgstate/failed ] && retuen 1

	opts=""
	test_xattr "${2}" && opts="${opts}X"
	test_acl   "${2}" && opts="${opts}A"

	rsync -aH${opts} "${1}"/ "${2}"/ && return 0
	
	# If we got this far then we failed.
	echo > /tmp/.lkgstate/failed
	return 1	
}

safe_ln()
{
	# If anything so far has failed then there is no point continuing.
	[ -f /tmp/.lkgstate/failed ] && retuen 1
	
	ln -sf "${1}" "${2}"
}

# Create the new logical volume if it doesn't exist already.
if [ ! -e "/dev/${1}/${3}_lkg_active" ]
then
	lvcreate -s -n "${3}_lkg_active" -L "${4}" --noudevsync "/dev/${1}/${3}"
	lvchange --addtag @lkg_active "/dev/${1}/${3}_lkg_active"
fi

# Copy the contents of the selected snapshot LV to the active snapshot LV
# and update the symbolic link in the /dev/lkg/ directory to point to the
# new snapshot. If we can't mount the source or the destination, or if
# the rsync fails create a /tmp/.lkgstate/failed file.
safe_mount "/dev/${1}/${2}" "/mnt/src" ro
safe_mount "/dev/${1}/${3}_lkg_active" "/mnt/dst" rw
safe_rsync /mnt/src /mnt/dst
safe_ln "/dev/${1}/${3}_lkg_active" "/dev/lkg/${1}/${3}"
umount /mnt/dst > /dev/null
umount /mnt/src > /dev/null
