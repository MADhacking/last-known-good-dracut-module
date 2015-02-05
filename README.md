last-known-good-dracut-module
=============================

Whenever a computer system is updated or reconfigured there is always the possibility that the new software or configuration may not function correctly. By extension it is also a possibility, after such an update or reconfiguration, that the next time the computer is rebooted such a problem could render the system unusable by compromising a critical boot-time service, such as the networking stack or SSH daemon. This often makes resolving such an issue time consuming and difficult, especially if you only have remote access to the machine in question.

The Last Known Good Configuration (LKGC) system presented here provides a Dracut module which leverages the LVM snapshot system to make point-in-time recovery images of tagged volumes as well as the Kernel, Initial RAM FS and Hypervisor (such as Xen) which were used to boot the system. Every time the system is successfully booted these snapshots are archived and may be selected as future restore points or duplicated and used as the basis for a Last Known Good system start. 

More information may be found at:

http://www.mad-hacking.net/software/linux/agnostic/last-known-good/index.xml
