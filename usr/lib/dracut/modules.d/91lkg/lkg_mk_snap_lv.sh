#! /bin/sh

# ${1} lv_name
# ${2} lv_size
# ${3} vg_name

# Create the snapshot.
lvcreate -s -n "${1}_lkgc" -L "${2}" --noudevsync "/dev/${3}/${1}" >/dev/null

# Tag the snapshot.
lvchange --addtag @lkg_candidate "/dev/${3}/${1}_lkgc" >/dev/null
