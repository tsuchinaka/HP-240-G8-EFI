# HP 240 G8 EFI

OpenCore EFI for the **HP 240 G8** laptop running **macOS Sequoia 15.8.1**.
Tested on an **HP 240 G8** with Intel Core **i3-1115G4**, Intel UHD Graphics
**0x9A78**, Realtek **RTL8822CE** Wi-Fi and an **ADATA LEGEND 710 256 GB** NVMe.

> Tested only on this exact machine. Other laptops, other NVMe drives, other
> Wi-Fi cards or other BIOS versions may need different SSDT, USB map, audio
> layout or DVMT settings.

> This is a community EFI, not an Apple or Realtek product. Use it at your own
> risk, keep a bootable backup, and never publish your real SMBIOS identifiers.

## Hardware

| Component | Model |
| --- | --- |
| Laptop | HP 240 G8 |
| CPU | Intel Core i3-1115G4 (Tiger Lake, 2C/4T) |
| iGPU | Intel UHD Graphics, device ID `0x9A78` |
| RAM | 16 GB (2x 8 GB DDR4 2667 MHz) |
| Storage | ADATA LEGEND 710 256 GB NVMe (only drive tested; others untested) |
| Display | 1366x768 eDP |
| Wi-Fi | Realtek RTL8822CE (`10EC:C822`, `10EC:C82F`) |
| Ethernet | Realtek RTL8111/8168H |
| Audio | Realtek ALC (AppleALC, `alcid=55`) |
| Input | VoodooI2C + VoodooPS2 |
| SMBIOS | `MacBookPro16,2` (`Mac-5F9802EFE386AA28`) |

## Software

| Component | Version |
| --- | --- |
| macOS | Sequoia 15.8.1 (24H32) |
| OpenCore | 1.0.8 DBG (`DBG-108-2026-09-27`) |
| Lilu | 1.7.2 |
| VirtualSMC / SMCBatteryManager | 1.3.8 |
| AppleALC | 1.9.8 |
| NVMeFix | 1.1.3 |
| BlueToolFixup | 2.7.2 |
| VoodooI2C / VoodooI2CHID | 2.9.1 / 1.0 |
| VoodooPS2Controller | 2.3.7 |
| RealtekRTL8111 | 2.4.2 |
| AMFIPass | 1.4.1 Mod |
| WhateverXe | 0.6.0 RELEASE |
| WhateverXe Graphics | 0.2.0 (Sequoia + Common receipts) |
| AppleIntelTGLCompat | 0.5.0 |
| AirPort_RTW88 | 2.0.1 |

## Status

Checked on the booted machine, Sequoia 15.8.1, 2026-10-27.

**Working**

- Metal 2 acceleration on the internal 1366x768 eDP panel, 1536 MB dynamic VRAM, 30-bit framebuffer. Brightness through `SSDT-PNLF`.
- Audio through Apple's `AppleHDA` 600.2 plus AppleALC `alcid=55`: internal speakers and the internal microphone are the default devices.
- Wi-Fi connects with AirPort_RTW88 2.0.1 after the Apple legacy IO80211 stack is added locally (see `docs/WIFI.md`).
- Keyboard (VoodooPS2) and trackpad (VoodooI2C).
- Ethernet kext (RTL8111 2.4.2) loads. A cable was not retested on this pass.
- Battery reporting (SMCBatteryManager).

**Not working, or not confirmed**

- WindowServer can still crash while scaling a detached IOSurface. The fault is a NULL write in `AppleIntelTGLGraphicsVADriver` at image offset `0x1336f3` (`+0x910`). WhateverXe 0.6.0 does not fix it.
- App Store video can freeze the GPU. This remains an upstream WhateverXe known issue.
- Bluetooth kexts load, but on this boot the controller radio was off and no devices were connected. Do not treat Bluetooth as confirmed.
- Sleep/wake is not validated.
- AWDL, AirDrop and Continuity are not supported by AirPort_RTW88.
- Wi-Fi can still drop: the AP deauthenticates with `reason 6`. Try WPA2-only and disable WPA3/PMF/802.11r before blaming the kext.
- Tahoe is not installed on this disk. Do not upgrade this volume in place. The installed graphics package is the Sequoia payload, and `CoreMedia / AllowOnePassMetalScaling` is not set.

**On the running ESP, not in this repository**

The booted `config.plist` also enables `IOSkywalkFamily`, `IO80211FamilyLegacy`, `AirPortBrcmNIC` and `HfsPlus.efi`. `SimpleHDA` 1.0.0 is enabled with `MinKernel` 25, so it does not load on Sequoia. `USBPorts.kext` is present and disabled. Those Apple binaries and SimpleHDA are not published here; the committed config leaves those entries disabled so a clone can boot without them.

## What is **not** included (and why)

To keep the repo redistributable, these Apple components are intentionally
missing:

- `IOSkywalkFamily.kext`
- `IO80211FamilyLegacy.kext` (and its `AirPortBrcmNIC.kext` plugin)
- `HfsPlus.efi`
- Apple's Tiger Lake graphics kexts and Metal/GL/VA bundles
  (`AppleIntelTGLGraphics*`, `AppleIntelTGLGraphicsFramebuffer`,
  `AppleIntelTGLGraphics*Driver.bundle`)

The corresponding `Kernel > Add` / `UEFI > Drivers` entries in `config.plist`
are **disabled**. Follow `docs/WIFI.md` and `docs/GPU.md` to add the official
components and enable them.

`SimpleHDA.kext` and `USBPorts.kext` are also not shipped; their entries are
disabled.

## SMBIOS: generate your own

The repository ships placeholders, never a real identity:

| Key | Placeholder |
| --- | --- |
| `SystemSerialNumber` | `C02XXXXXXXXX` |
| `MLB` | `00000000000000000` |
| `SystemUUID` | `00000000-0000-0000-0000-000000000000` |
| `ROM` | `000000000000` |

Generate a fresh SMBIOS with [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS)
for `MacBookPro16,2`, prefer a serial that returns *"unable to check coverage"*
on Apple's coverage page, and set `ROM` to your `en0` MAC address in lowercase
without colons. Full steps: `docs/INSTALL.md`.

## BIOS / UEFI

- DVMT Pre-Allocated: **256 MB** (96 MB works; 60 MB needs the WhateverXe
  workaround in `docs/GPU.md`)
- CFG Lock: disabled
- Secure Boot: off
- Fast Boot: off
- VT-d: depends on your OpenCore configuration (`DisableIoMapper`)

## Installation

1. Back up your current EFI (`dd` or a full copy).
2. Read `docs/INSTALL.md` and set your own SMBIOS + ROM.
3. Install the **WhateverXe Graphics** package for the Tiger Lake graphics
   stack (`docs/GPU.md`).
4. Add the Apple legacy Wi-Fi stack and enable the disabled entries
   (`docs/WIFI.md`).
5. Copy `EFI/` to the ESP and reset NVRAM from the OpenCore picker.

## Repository layout

```
EFI/
  BOOT/BOOTx64.efi
  OC/
    ACPI/*.aml
    Drivers/OpenRuntime.efi
    Kexts/            # redistributable kexts only
    OpenCore.efi
    config.plist      # sanitized placeholders
docs/
  HARDWARE.md
  INSTALL.md
  WIFI.md
  GPU.md
  TROUBLESHOOTING.md
LICENSES/
scripts/check-efi.sh
README.md
LICENSE
THIRD_PARTY_NOTICES.md
```

## Credits

OpenCore, Lilu, VirtualSMC, AppleALC, NVMeFix, VoodooPS2, VoodooI2C,
WhateverXe, AirPort_RTW88 and the rest of the components belong to their
respective authors. See `THIRD_PARTY_NOTICES.md` and `LICENSES/`.

## License

The original configuration, documentation and scripts in this repository are
released under the **MIT License** (`LICENSE`). Third-party components keep
their own licenses; Apple components are not distributed here.

## Disclaimer

This project is not affiliated with, endorsed by, or supported by Apple,
Realtek, or any hardware vendor. macOS and Apple components remain Apple's
property. Use this EFI only on hardware you own and at your own risk.
