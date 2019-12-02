# Patching Ridge NVM

The ThunderboltReset plugin disables the ARC processor built into the Ridge and 
allows OSX to take over as the LC. However, this reset-after-boot is an Intel 
unsupported use case and you will run into a lot of annoying hardware issues 
(such as random system panics after wakeup). A better solution is to patch the 
NVM (Ridge firmware) into an Apple configuration.

This guide is for **advanced users** only. Note that flashing the Ridge 
can result in a brick resulting in inoperable TB3/USB-C ports. If that is the 
case, you need to manually recover with an external SPI flasher. You should be 
aware of the risks here.

## Quick note on signed firmwares

It appears that Apple Ridge firmwares are signed with a different private key 
than the Ridge firmwares found on literally every other device. That means that 
you cannot just flash an Apple firmware. If you could, things would be a lot 
easier. The next best option is to break the signature with a patched firmware. 
However, in doing so, you lose Thunderbolt support in Windows and Linux (can be 
worked around). USB 3.0 should still function with a patched firmware.

## Extracting Apple USB-C firmwares

To dump all the different USB-C firmwares from OSX installer, you need to run 
`pkgutil --expand-full FirmwareUpdate.pkg path/to/output`. This pkg is found in 
`InstallESD.dmg` on newer OSX installers.

Now in `path/to/output/Scripts/Tools/USBCUpdater` you will find the firmwares 
for all the different Mac models (including those without Thunderbolt, which 
just updates the TI PD firmware).

## Dumping your firmware

The easiest way to get your original firmware is to find an update for your 
board's Thunderbolt controller online. You can also dump it externally with a 
SPI flasher. Finally, you can use [ThunderboltPatcher][1] to dump it, but this 
requires you to use the ThunderboltReset plugin.

## Finding the active partition

To find the start of the active partition in a dump/firmware update, first look 
at the first 4 bytes. If it is not `FF FF FF FF`, then that is the starting 
offset (in little endian) of the active partition. If it is `FF FF FF FF`, then 
look at the 4 bytes starting at offset 0x1000. That should be the starting 
offset (in little endian) of the active partition.

## Matching firmware

First, you need to figure out the version number for your existing firmware. 
If you downloaded it from the OEM's web site, the file name will usually tell 
you what the version is. For example 
`Intel_Hades_AR_HR_4C_C0_rev33_W_TI_20180109_SEC1_sign.bin` is version 33.

If you have a raw dump, look at the byte at offset 0xA of the active partition 
(directions for finding the active partition is in the section above). For 
example if the byte is (hex) `19` then it is version 19.

Now you want to find the Apple Ridge firmware closest to this version. In the 
`USBCUpdater` directory, you will find a lot of Mac models, each containing a 
`Config.plist` file. Look for `<key>Ridge Firmware Version</key>` (if that does 
not exist, then that model does not have a Thunderbolt controller). Compare the 
version there with the one for your board. You may have to dump different 
versions of OSX installer to get older Ridge firmwares (someone should make a 
central database).

Ideally, you want one that is +/- 2 versions away from your board's version. 
The reason is that the config section of the firmware (where we will be 
copying from) contains some size/offset fields. If those change, then the diff 
process will be a lot more complicated. I've noticed that those fields usually 
stay constant for many versions. You can be sure that no size/offset fields 
changed by using a diff tool and checking that no bytes are added or removed 
(only changed) after ignoring the DROM.

## Patching firmware

Using a binary diff tool (such as Araxis Merge or HxD), compare the first 
0x1000 bytes *of the active partition* in the two firmware. You can now create 
a [ThunderboltPatcher patch][2] for your firmware.

You can skip the follow differences:

* Offset 0xA-0xB has the version number
* Offset 0x200-0x600 is the DROM
* Any time you see the version number (e.g. `33` vs `34` if your controller 
  is v33 and Apple's is v34)
* Any time you see `86 80 XX XX` from Apple's firmware (controller PID) and 
  your board's firmware is NOT `FF FF FF FF`.

[1]: https://github.com/osy86/ThunderboltPatcher
[2]: https://github.com/osy86/ThunderboltPatcher/blob/master/README.md
