# Custom Kernel Launcher for Scaleway
A collection of scripts to load a custom kernel on Scaleway servers

# Disclaimer

This project is not affiliated with nor endorsed by Scaleway or Online SAS in any way.

Scaleway is a trademark of Online SAS.

# Introduction

The virtual (i.e. not-baremetal) servers available on Scaleway are run [within KVM](https://www.scaleway.com/faq/server/#-Which-hypervisor-do-you-use). In theory, this gives you a proper virtual machine that you can do whatever you wish within.

However, there currently is no official support for booting a custom kernel, as might be necessary for some more obscure or very new features, or custom patches.

Luckily, Scaleway has kindly enabled [`kexec`](https://wiki.archlinux.org/index.php/kexec) on their servers. This lets us replace the currently running kernel with another one.

With a couple of scripts, we can get this to automatically happen on boot, which gives us a pretty seamless way to get into a custom kernel.

# Supported platforms

Currently, this is written for the official Scaleway Ubuntu 16.04 image and tested on a VC1S, VC1M and X64-15GB. It might need some tweaking for other distros, or for use on the baremetal servers.

# Instructions

You are expected to be running as root. The install scripts are written for a clean image, and might overwrite other settings.

1. Clone this repository somewhere.

2. Install a custom or distro-official kernel. In Ubuntu, this can be accomplished with `apt install linux-generic`. You are expected to end up with a `/vmlinuz` and `/initrd.img` file in the root. If it prompts you, do **not** install grub on any devices - leave them all unticked and press enter, then yes continue without installing grub.

3. Install `kexec`. In Ubuntu, `apt install kexec-tools`. If it prompts you, you do **not** want it to handle reboots.

4. Run `install.sh`. This will copy some configs necessary to get prevent errors during the boot.

5. Run `uname -r` and record the output. This is your old (Scaleway) kernel.

6. Test by running `systemctl kexec`, which should switch into the new kernel. You will need to reconnect.

7. Check `uname -r` again -- you should now be in your new (custom) kernel.

8. If the manual reboot worked, you can enable auto-switch on boot by running `enable-autostart.sh`. If it did not work, I would recommend figuring out why first so you do not get stuck in an unbootable system.

# Details

This is mostly based off the simple `kexec` commands described on the [Archlinus wiki](https://wiki.archlinux.org/index.php/kexec). There are some adjustments:

* `/etc/fstab` needs an entry added to set the root filesystem to `rw`, otherwise it's in readonly.

* `/etc/udev/rules.d` needs a config that sets the network interface to `eth0`, since the Ubuntu kernel by default uses [a different naming scheme](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/). Alternative methods include either disabling the new naming by setting `net.ifnames=0` in the kernel command line (`--append` arg on kexec) or changing the interface name away from `eth0` in `/etc/network/interfaces`.

* Some systemd entries are added to load the correct image (edit `/etc/systemd/system/sckl-kexec-load.service` to change the `kexec` command line) and to run it on boot if enabled (the trigger service).

* A systemd override is applied to disable the Scaleway `scw-generate-ssh-keys.service`, which otherwise errors on startup. It's supposed to be a one-off generation anyway so hopefully not too important.

## Other platforms

I expect this to work on all the VPSes. If you're using it on the baremetal servers, you might need to configure the root device in `/etc/fstab`, since it's probaby not `/dev/vda`... The network interface in the udev rule also needs to be updated, since it's currently pinned to the KVM `virtio` name.

For other distros, you might need to customise the systemd scripts appropriately. The network interface rules might also need to be updated.


