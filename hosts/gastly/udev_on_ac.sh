##Change Dirty Writeback Centisecs according to TLP / Powertop
echo '500' > '/proc/sys/vm/dirty_writeback_centisecs';

##Change AMD Paste EPP energy preference
##Available profiles: performance, balance_performance, balance_power, power
echo 'balance_performance' > tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference;

##If required, change cpu scaling governor
#cpupower frequency-set -g performance;

##Platform Profiles Daemon will do this automatically, based on your settings in KDE / GNOME
##You can how ever, set this manually as well
##Possible profile options are: performance, powersave, low-power
#echo 'performance' > '/sys/firmware/acpi/platform_profile';

##Radeon AMDGPU DPM switching doesn't seem to be supported.
##Possible options should be: battery, balanced, performance, auto
#echo 'performance' > '/sys/class/drm/card0/device/power_dpm_state';

##Should always be auto (TLP default = auto)
##Possible options are: auto, high, low
#echo 'auto' > '/sys/class/drm/card0/device/power_dpm_force_performance_level';

##Runtime PM for PCI Device to on
find /sys/bus/pci/devices/*/power -name control -exec echo auto >{} \;
for i in $(find /sys/devices/pci0000\:00/0* -maxdepth 3 -name control); do
    echo on > $i;
done
