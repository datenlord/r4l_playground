#!/bin/env bash
cd out_of_tree_mod
make -C /linux/build M=$PWD rust-analyzer
cd ../pci_net_dev
make -C /linux/build M=$PWD rust-analyzer

mkdir -p ./vscode && touch ./vscode/settings.json

echo "In order to make RA works, you might need to add the following config to .vscode/settings.json:"
echo "    {"
echo '        "rust-analyzer.linkedProjects": ["playground/out_of_tree_mod/rust-project.json", "playground/pci_net_dev/rust-project.json"]'
echo "    }"
