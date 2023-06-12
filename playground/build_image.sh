#!/bin/env bash
cd /rootfs
find . | cpio -o --format=newc > /rootfs.img
