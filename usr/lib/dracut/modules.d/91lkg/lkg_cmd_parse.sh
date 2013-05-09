#! /bin/sh

LKG_SNAPSHOT=$(getargs rd.lkg.snapshot)

[ -n "${LKG_SNAPSHOT}" ] && echo "${LKG_SNAPSHOT}" > /tmp/lkg.snapshot
