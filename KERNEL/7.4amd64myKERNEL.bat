#! /bin/sh

MY_PATH="`echo $0 | sed s/'\/[^\/]*$'//g`"

# USB devices
${MY_PATH}/kernel_slimming.bat 234 361
mv -v GENERIC_MY_KERNEL GENERIC

# Networking devices
${MY_PATH}/kernel_slimming.bat 498 563
mv -v GENERIC_MY_KERNEL GENERIC

# Wireless network cards
${MY_PATH}/kernel_slimming.bat 565 596
mv -v GENERIC_MY_KERNEL GENERIC

# mii & MIDI & Audio
${MY_PATH}/kernel_slimming.bat 598 681
mv -v GENERIC_MY_KERNEL GENERIC

# FM-Radio support
${MY_PATH}/kernel_slimming.bat 683 688
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

