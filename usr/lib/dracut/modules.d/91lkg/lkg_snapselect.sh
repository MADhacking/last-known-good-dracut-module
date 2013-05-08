#! /bin/sh

# If there is NOT an LKG_BOOT_SNAPSHOT variable defined then
# we don't need to run so just return.
[ -z ${LKG_BOOT_SNAPSHOT} ] && return

info "Last Known Good (LKG) [phase 2] - Duplicating selected LKG snapshots"

