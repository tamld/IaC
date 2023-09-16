#!/bin/bash
# Destroy all VM and CT with VMID smaller than 200
for i in $(qm list | awk '{ print $1 }' | tail -n +2); do
    if [ $i -lt 200 ]; then
        echo "Destroying VM with ID: $i"
        qm stop $i
        qm destroy $i
    fi
done

for i in $(pct list | awk '{ print $1 }' | tail -n +2); do
    if [ $i -lt 200 ]; then
        echo "Destroying CT with ID: $i"
        pct stop $i
        pct destroy $i
    fi
done