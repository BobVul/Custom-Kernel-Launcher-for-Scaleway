#!/bin/sh

cp -r configs/* /
systemctl enable scaleway-customkernel-load.service
