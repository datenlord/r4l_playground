#!/bin/env bash
cd out_of_tree_mod
make -C /linux/build M=$PWD rust-analyzer
cd ../pci_net_dev
make -C /linux/build M=$PWD rust-analyzer
