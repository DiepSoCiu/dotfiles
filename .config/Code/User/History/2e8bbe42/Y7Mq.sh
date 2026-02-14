#!/bin/bash
rm -f /dev/shm/looking-glass
dd if=/dev/zero of=/dev/shm/looking-glass bs=1M count=128 2>/dev/null
chown diepsociu:kvm /dev/shm/looking-glass
chmod 660 /dev/shm/looking-glass