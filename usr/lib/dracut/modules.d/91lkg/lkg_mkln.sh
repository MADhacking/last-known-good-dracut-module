#! /bin/sh

# ${1} lv_name
# ${2} lv_size
# ${3} vg_name

# Create the symbolic link.
mkdir -p "/dev/lkg/${3}"
ln -sf "/dev/${3}/${1}" "/dev/lkg/${3}/${1}"
