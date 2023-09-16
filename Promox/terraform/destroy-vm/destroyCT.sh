#!/bin/bash
# Destroy all CT with VMID smaller than 200
for i in $(pct list | awk '{ print $1 }' | tail -n +2); do
    if [ $i -lt 200 ]; then
        echo "Destroying CT with ID: $i"
        pct stop $i
        pct destroy $i
    fi
done