#! /bin/sh

MY_PATH="`echo $0 | sed s/'\/[^\/]*$'//g`"

# USB devices
${MY_PATH}/kernel_slimming.bat 230 357
mv -v GENERIC_MY_KERNEL GENERIC

# Networking devices
${MY_PATH}/kernel_slimming.bat 494 558
mv -v GENERIC_MY_KERNEL GENERIC

# Wireless network cards
${MY_PATH}/kernel_slimming.bat 560 590
mv -v GENERIC_MY_KERNEL GENERIC

# mii & MIDI & Audio
${MY_PATH}/kernel_slimming.bat 592 673
mv -v GENERIC_MY_KERNEL GENERIC

# FM-Radio support
${MY_PATH}/kernel_slimming.bat 677 678
mv -v GENERIC_MY_KERNEL GENERIC

# Devices at pci
${MY_PATH}/kernel_slimming.bat pci
mv -v GENERIC_MY_KERNEL GENERIC

# Devices at acpi
${MY_PATH}/kernel_slimming.bat acpi
mv -v GENERIC_MY_KERNEL GENERIC

# Devices at iic
${MY_PATH}/kernel_slimming.bat iic
mv -v GENERIC_MY_KERNEL GENERIC

# Devices at isa
${MY_PATH}/kernel_slimming.bat isa

