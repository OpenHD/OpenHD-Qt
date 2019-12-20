# qt-raspberrypi

Qt builds for Raspberry Pi with EGLFS enabled


Note: this script must be run on a Raspberry Pi running Raspbian Stretch, or from
inside a chroot on a Raspbian Stretch image.

Generally all you need to do to enter an ARM chroot while running on an x86 Linux machine
is `apt install qemu binfmt-support qemu-user-static`, then `chroot /path/to/imageroot /bin/bash`.

This will transparently run the ARM binaries from inside the chroot on the host CPU, even though
it's x86.

However because we're building Qt, it requires a very large amount of storage. You should rsync 
the image contents to a directory on your Linux machine and chroot into *that* instead of the image
itself to avoid running out of space.

Also note that if building on a Raspberry Pi, you will have to run the build script with just one
process instead of the default 5 to avoid running out of RAM. Change `make -j5` to `make -j1` in
`build.sh`.


