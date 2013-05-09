#! /bin/sh

# If there is NOT a /tmp/lkg.snapshot file then we don't need to run.
[ ! -f "/tmp/lkg.snapshot" ] && return

read LKG_BOOT_SNAPSHOT < /tmp/lkg.snapshot

info "Last Known Good (LKG) [phase 2] - Duplicating selected LKG snapshots [${LKG_BOOT_SNAPSHOT}]"

# Clean and create our state directory.
rm -rf /tmp/.lkgstate 
mkdir -p /tmp/.lkgstate

# Loop through the volumes tagged with @lkg_snapshot.  When we
# come to the one specified by LKG_BOOT_SNAPSHOT (for each origin)
# we can make a copy of that volume.
lvs --noheadings --separator " " -o lv_name,origin,origin_size,vg_name --sort origin,-lv_name @lkg_snapshot | \
{
	last_origin=""
	while read lv_name origin origin_size vg_name
	do
		if [ "${last_origin}" != "${origin}" ]
		then
			last_origin="${origin}"
			snap_count=1
		fi
		
		if [ "${last_origin}" = "${origin}" ]
		then
			if [ ${snap_count} -eq ${LKG_BOOT_SNAPSHOT} ]
			then
				/sbin/lkg_mk_copy_lv.sh "${vg_name}" "${lv_name}" "${origin}" "${origin_size}"
				echo > /tmp/.lkgstate/located
			fi
			snap_count=$(($snap_count + 1))
		fi
	done
}

# If we failed to duplicate any volumes then we can't continue with the boot process.
if [ -f /tmp/.lkgstate/failed ]
then
	info "Last Known Good (LKG) [phase 2] - UNABLE TO DUPLICATE LAST KNOWN GOOD"
	return 1
fi

# If we failed to locate any volumes then we can't continue with the boot process.
if [ ! -f /tmp/.lkgstate/located ]
then
	info "Last Known Good (LKG) [phase 2] - UNABLE TO LOCATE LAST KNOWN GOOD ${LKG_BOOT_SNAPSHOT}"
	return 1
fi

rm -rf /tmp/.lkgstate 
	