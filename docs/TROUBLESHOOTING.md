# Troubleshooting

## Wi-Fi connects and then drops

See `docs/WIFI.md`. The usual cause is the AP deauthenticating with
`reason 6` after a security/PMF/WPA3 mismatch. Test WPA2-only, disable
PMF/802.11r/band steering, turn off Private Wi-Fi Address, and test 5 GHz vs
2.4 GHz.

## GPU panic: `PG2 power well fuse distribution failed`

See `docs/GPU.md`. It is a Tiger Lake display power-well failure, not DVMT.
Boot with `-wexoff` to confirm WhateverXe is involved, remove external
displays/docks, and report the panic upstream.

## Sleep / wake

Sleep is not fully validated with WhateverXe. USB-C display output can keep
part of the display hardware awake. If wake panics or the screen stays black:

1. Disconnect external displays before sleeping.
2. Test with `-wexoff`.
3. If needed, disable sleep (`sudo pmset -a sleep 0`) while you investigate.

## iServices (iMessage, FaceTime, App Store)

iServices need a **unique** SMBIOS and a working `en0`. The repository ships
placeholders on purpose:

- Generate a serial/MLB with GenSMBIOS for `MacBookPro16,2`.
- Set `SystemUUID` with `uuidgen`.
- Set `ROM` to your `en0` MAC.
- Reset NVRAM and sign in again.

Never publish your real serial, MLB, UUID or ROM. They are tied to your Apple
ID and can conflict with other machines.

## EFI does not mount or shows `.Trashes` errors

This is a FAT directory inconsistency, not necessarily a broken OpenCore.
Back up first, then repair:

```sh
sudo dd if=/dev/rdisk0s1 of=~/efi-backup.img bs=1m
sudo fsck_msdos -y /dev/disk0s1
sudo diskutil mount disk0s1
```

Do not mount the ESP read-write and drag files to the Trash. Use `rm`/`mv` and
unmount with `sudo diskutil unmount disk0s1`.

## OpenCore writes `opencore-*.txt` to the ESP

This EFI was built with OpenCore 1.0.8 **DBG**. `Misc > Debug > Target` is set
to `3`, so it should only log to the console. If you still get log files, set
`Target` to `0` or replace the bootloader with the 1.0.8 **RELEASE** build as
described in `docs/INSTALL.md`.

## No audio

`AppleALC` is configured with `alcid=55`. If your codec needs another layout,
change the boot argument to the correct layout ID and test. Keep `SSDT-EC-USBX`
and `SSDT-PNLF`.

## Battery / trackpad

Battery uses `SMCBatteryManager` and `SSDT-BATT`. The trackpad uses
`VoodooI2C`/`VoodooI2CHID` and `VoodooPS2Controller`. If the trackpad does not
work, check the `VoodooI2C` GPIO pinning and the ACPI `SSDT-GPI0` for your
specific board.

## USB ports

`USBPorts.kext` is not included and its entry is disabled. If you need a
specific USB map, build one with USBToolBox for your board and enable the kext.

## Bluetooth

Bluetooth is provided by `BlueToolFixup` + `RealtekBluetoothFirmware`, separate
from Wi-Fi. On 2.4 GHz, Bluetooth coexistence can affect Wi-Fi; test 5 GHz or
disable Bluetooth to isolate.

## Boot failure

- Keep a bootable USB and the `efi-backup.img`.
- Boot with `-v` to see where it stops.
- Reset NVRAM from the OpenCore picker (Space -> Reset NVRAM).
- Restore your previous EFI if a config change prevents boot.
