#! /bin/sh

. /lib/dracut-lib.sh

info "Last Known Good (LKG) [phase 1]"

# Get a list of the logical volumes to snapshot and
# create symbolic links to them in /dev/lkg/*
lvs --noheadings --separator " " -o lv_name,lv_size,vg_name @lkg_source | \
	xargs -L1 /sbin/lkg_mkln.sh 2>&1 | vinfo
