# Installation

This EFI is for a Tiger Lake laptop with the hardware described in
`docs/HARDWARE.md`. It boots macOS Sequoia 15.8.1, but you must generate your
own SMBIOS and install the components that cannot be redistributed.

## 0. Back up your working EFI

Always keep a bootable USB or a raw image of your ESP:

```sh
diskutil list
sudo dd if=/dev/rdisk0s1 of=~/efi-backup.img bs=1m
```

## 1. Mount the ESP

```sh
sudo diskutil mount disk0s1
open /Volumes/EFI
```

The ESP is normally `disk0s1`; confirm the identifier with `diskutil list`.

> Do not mount the ESP read-write and drag files to the Trash. macOS creates
> `.Trashes` on the FAT volume and can corrupt the directory entries. Use
> `rm` or `mv`, and unmount with `sudo diskutil unmount disk0s1`.

## 2. Generate your own SMBIOS

The repository ships placeholders. Do not reuse anyone else's serial, MLB or
UUID.

```sh
git clone https://github.com/corpnewt/GenSMBIOS
cd GenSMBIOS
chmod +x GenSMBIOS.command
./GenSMBIOS.command
```

1. Option **1** to install/update `macserial`.
2. Option **3** and enter `MacBookPro16,2 10`.
3. Pick a serial that returns **"We're sorry, we're unable to check coverage
   for this serial number."** on <https://checkcoverage.apple.com/>. Avoid
   serials with a valid purchase date.
4. Keep the matching **MLB** (Board Serial) that GenSMBIOS prints.

Generate a UUID:

```sh
uuidgen
```

Set these in `EFI/OC/config.plist` under `PlatformInfo > Generic` (use
ProperTree or OCAT):

| Key | Value |
| --- | --- |
| `SystemProductName` | `MacBookPro16,2` |
| `SystemSerialNumber` | your generated serial |
| `MLB` | your generated MLB (17 characters) |
| `SystemUUID` | the output of `uuidgen` |
| `ROM` | your `en0` MAC, lowercase, no colons, as Data |
| `Automatic` | `true` |

Get the MAC of your built-in Ethernet (`en0`) with:

```sh
networksetup -listallhardwareports | grep -A2 "Ethernet"
```

Convert `aa:bb:cc:dd:ee:ff` to the Data value `aabbccddeeff`.

Validate the file:

```sh
plutil -lint EFI/OC/config.plist
```

## 3. Install the Tiger Lake graphics stack

The Apple Tiger Lake kexts and Metal/GL/VA bundles are **not** in this repo.
Install the signed WhateverXe Graphics package, which places them in
`/Library/Extensions` and `/Library/GPUBundles` and rebuilds the auxiliary
kernel collection:

- WhateverXe Graphics: <https://github.com/b00t0x/WhateverXe-Graphics/releases>
- WhateverXe release: <https://github.com/b00t0x/WhateverXe/releases>
- AMFIPass v1.4.1 Mod (if you replace the bundled one):
  <https://github.com/b00t0x/WhateverXe-Graphics/blob/main/extras/AMFIPass-v1.4.1-Mod-RELEASE.zip>

The EFI already contains `WhateverXe.kext` and `AMFIPass.kext`. Do **not** load
WhateverGreen and WhateverXe at the same time.

See `docs/GPU.md` for DVMT and boot arguments.

## 4. Add the Apple legacy Wi-Fi stack

`AirPort_RTW88` needs the legacy `IO80211`/`IOSkywalk` components on Sonoma and
later. Those files are Apple property and are **not** included here:

- `IOSkywalkFamily.kext`
- `IO80211FamilyLegacy.kext` (with its `AirPortBrcmNIC.kext` plugin)

Obtain them from the official AirPort_RTW88 / `Edwardwich/BCM-WIFI-Sequoia`
instructions, copy them into `EFI/OC/Kexts`, and then enable the four disabled
entries in `Kernel > Add`:

| BundlePath | MinKernel |
| --- | --- |
| `IOSkywalkFamily.kext` | `22.0.0` |
| `IO80211FamilyLegacy.kext` | `22.0.0` |
| `IO80211FamilyLegacy.kext/Contents/PlugIns/AirPortBrcmNIC.kext` | `22.0.0` |
| `AirPort_RTW88.kext` | `22.0.0` |

`AirPort_RTW88.kext` (2.0.1) is included in this repo under its own license.
`HS80211Family.kext` and `Realtek88LegacyAirport.kext` are for Mojave/Catalina/
Big Sur; they are not used here.

See `docs/WIFI.md` for the known `reason 6` deauthentication problem.

## 5. HfsPlus.efi (only if your firmware needs it)

The repo does not ship Apple's `HfsPlus.efi`. Copy it from the OpenCorePkg
release (or OCAT) into `EFI/OC/Drivers` and enable the `HfsPlus.efi` entry
under `UEFI > Drivers`. On APFS-only systems the firmware's APFS driver is
usually enough; leave it disabled if you do not need HFS+.

## 6. BIOS / UEFI settings

- DVMT Pre-Allocated: **256 MB** (96 MB works; 60 MB needs the workaround in
  `docs/GPU.md`)
- CFG Lock: **disabled**
- Secure Boot: **off**
- Fast Boot: **off**
- VT-d: depends on your OpenCore configuration (`DisableIoMapper`)

## 7. Copy the EFI and reset NVRAM

```sh
# from the repository root, with the ESP mounted
sudo cp -R EFI/* /Volumes/EFI/EFI/
sudo diskutil unmount disk0s1
```

`AllowNvramReset` is enabled in this config. At the OpenCore picker press
**Space** and choose **Reset NVRAM**, then boot macOS.

## 8. First boot checks

- `system_profiler SPDisplaysDataType` should show Metal support.
- `system_profiler SPAirPortDataType` should show the RTL8822CE and your
  networks (after the legacy stack is added).
- `kextstat | grep -iE "WhateverXe|AppleIntelTGL|AirportRTW88"` should show the
  graphics and Wi-Fi stacks.
- `csrutil status` should match `csr-active-config` (`03080000`).

## Note on the OpenCore build

This EFI was tested with **OpenCore 1.0.8 DBG**. For a production machine you
can replace these three files with the 1.0.8 **RELEASE** build from
<https://github.com/acidanthera/OpenCorePkg/releases/tag/1.0.8>:

- `EFI/BOOT/BOOTx64.efi`
- `EFI/OC/OpenCore.efi`
- `EFI/OC/Drivers/OpenRuntime.efi`

The `config.plist` is compatible with both. `Misc > Debug > Target` is set to
`3` so the DBG build does not write `opencore-*.txt` logs to the ESP.
