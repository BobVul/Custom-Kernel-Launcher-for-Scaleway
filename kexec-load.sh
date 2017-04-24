#/bin/sh

kexec -l /vmlinuz --initrd=/initrd.img --reuse-cmdline
