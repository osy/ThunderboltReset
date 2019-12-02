# Patching ACPI

Once the native LC is disabled through either ThunderboltReset or 
[native NVM patches][1], you need custom ACPI entries to support power 
management (including S3hot) and hot-plug.

## New Board

Start by making a copy of the closest board config in `ThunderboltNative` and 
name it `SSDT-TbtOnPCH-TARGETNAME.asl`.

There are a list of defines near the top of the file that must be changed:

1. `TBT_HOTPLUG_GPE`: details in the next section
2. `TBT_ROOT`: Root device path for TB controller. Use `ioreg` and find the PCI 
   device that connects to a `AppleThunderboltHAL`.
3. `TBT_HAS_COMPANION`: Companion device used only for power saving on boards 
   that support it. Safe to always disable.
4. `XHC_ROOT`: Only used with companion device. Path to XHCI controller where 
   the companion ports are connected to.
5. `TBT_USB_PORT_1_COMPANION`: Only used with companion device.
   First port number.
6. `TBT_USB_PORT_2_COMPANION`: Only used with companion device.
   Second port number.

## Finding GPE

1. Have Thunderbolt working either with the ThunderboltReset plugin or patched 
   NVM.
2. Install [RehabMan's ACPI logger][2].
3. Dump your DSDT/SSDT tables and find all methods with names beginning with 
   `_L` and `_E`.
4. Modify the template in `ThunderboltNative/SSDT-HPLog.asl` with your GPE 
   candidates.
5. Build and install `ThunderboltNative/SSDT-HPLog.asl`.
6. Add the ACPI patches to your config.plist renaming all the different `_Lxx` 
   and `_Exx` method names to `XLxx` and `XExx` where `xx` is each GPE number.
7. Reboot with a TB device plugged in.
8. Open a Terminal and type in `log stream --process 0 | grep ACPI`
9. Unplug and re-plugin the TB device
10. Look at the Terminal window to see which GPE is printed. That is your 
   hotplug GPE.
11. You can delete all the ACPI patches from config.plist except for the 
   hotplug GPE.

## Building ACPI

Have [iasl][3] in your `PATH` and run `make TARGET=TARGETNAME` in 
`ThunderboltNative`.

[1]: [PatchingNVM.md]
[2]: [https://github.com/RehabMan/OS-X-ACPI-Debug]
[3]: [https://bitbucket.org/RehabMan/acpica/downloads/]
