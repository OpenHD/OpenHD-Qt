# qt-raspberrypi

Qt builds for Raspberry Pi with EGLFS enabled


Note: this script must be run on a Raspberry Pi running Raspbian Stretch, or from
inside a chroot on a Raspbian Stretch image.

Generally all you need to do to enter an Arm chroot while running on an x86 Linux machine
is install qemu-arm-user-static, and then do `chroot /path/to/imageroot /bin/bash`. 

However because we're building Qt, it requires a very large amount of storage. You should
instead *mount* the image and rsync the contents to a directory on your linux machine and 
chroot into *that* instead of the image itself.


