# Qt-OpenHD

Qt builds for OpenHD with all the features we need.


Note: this script must be run on a real device, it is not for crosscompiling.

Generally all you need to do to enter an ARM chroot while running on an x86 Linux machine
is `apt install qemu binfmt-support qemu-user-static`, then `chroot /path/to/imageroot /bin/bash`.

Also note that if building on a Raspberry Pi, you will have to run the build script with just one
process instead of the default 5 to avoid running out of RAM. Change `make -j12` to `make -j1` in
`build.sh`, also adding swap doesn't hurt.


