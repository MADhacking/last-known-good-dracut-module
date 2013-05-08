#! /bin/sh

info "Last Known Good (LKG) [phase 2]"

# Remove any existing snapshot candidates. >/dev/null
info "    removing stale candidate snapshots"
lvremove --force --noudevsync @lkg_candidate 2>&1 | vinfo

# Get a list of the logical volumes to snapshot and
# create a snapshot of them.
info "    creating new snapshot candidates"
lvs --noheadings --separator " " -o lv_name,lv_size,vg_name @lkg_source | \
	xargs -L1 /sbin/lkg_mklv.sh 2>&1 | vinfo
