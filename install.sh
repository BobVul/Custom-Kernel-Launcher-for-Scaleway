#!/bin/sh

cp -r configs/* /
systemctl enable sckl-kexec-load.service
