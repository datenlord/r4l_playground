#!/bin/env bash

cp ./**/*.ko /rootfs/
cd /rootfs
find . | cpio -o --format=newc > /rootfs.img
