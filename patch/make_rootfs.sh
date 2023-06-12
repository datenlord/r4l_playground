#!/bin/sh
rootfs="rootfs"

if [ ! -d $rootfs ]; then 
	mkdir $rootfs
fi
cp _install/*  $rootfs/ -rf
cd $rootfs
if [ ! -d proc ] && [ ! -d sys ] && [ ! -d dev ] && [ ! -d etc/init.d ]; then
	mkdir proc sys dev etc etc/init.d
fi
 
if [ -f etc/init.d/rcS ]; then
	rm etc/init.d/rcS
fi
echo "#!/bin/sh" > etc/init.d/rcS
echo "mount -t proc none /proc" >> etc/init.d/rcS
echo "mount -t sysfs none /sys" >> etc/init.d/rcS
echo "/sbin/mdev -s" >> etc/init.d/rcS
chmod +x etc/init.d/rcS