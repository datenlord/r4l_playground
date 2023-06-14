#!/bin/env bash
cd /linux
make LLVM=1 O=build compile_commands.json
