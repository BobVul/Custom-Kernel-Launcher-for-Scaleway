#/bin/sh

kexec -l /vmlinuz --initrd=/initrd.img --reuse-cmdline --append=sckl-kernel-loaded
systemctl kexec
