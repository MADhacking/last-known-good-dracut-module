#! /bin/sh

# If there is a /tmp/lkg.snapshot file then we don't need to run.
[ -f "/tmp/lkg.snapshot" ] && return

info "Last Known Good (LKG) [phase 2] - Creating LKG candidate snapshots"

# Remove any existing snapshot candidates.
info "    removing stale candidate snapshots"
lvremove --force --noudevsync @lkg_candidate 2>&1 | vinfo
lvremove --force --noudevsync @lkg_active 2>&1 | vinfo

# Get a list of the logical volumes to snapshot and
# create a snapshot of them.
info "    creating new snapshot candidates"
lvs --noheadings --separator " " -o lv_name,lv_size,vg_name @lkg_source | \
	xargs -L1 /sbin/lkg_mk_snap_lv.sh 2>&1 | vinfo
