# MacBookPro16,2-style Tiger Lake Hackintosh EFI

OpenCore EFI for a **Tiger Lake** laptop running **macOS Sequoia 15.8.1**.
Tested on an Intel Core **i3-1115G4** with Intel UHD Graphics **0x9A78** and a
Realtek **RTL8822CE** Wi-Fi card.

> This is a community EFI, not an Apple or Realtek product. Use it at your own
> risk, keep a bootable backup, and never publish your real SMBIOS identifiers.

## Hardware

| Component | Model |
| --- | --- |
| CPU | Intel Core i3-1115G4 (Tiger Lake, 2C/4T) |
| iGPU | Intel UHD Graphics, device ID `0x9A78` |
| RAM | 16 GB |
| Storage | 256 GB NVMe |
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
| AMFIPass | 1.4.1 |
| WhateverXe | 0.4.0 |
| AirPort_RTW88 | 2.0.1 |

## Status

**Working**

- Metal 2 / OpenGL acceleration, 1536 MB dynamic VRAM
- Internal 1366x768 eDP display and brightness (`SSDT-PNLF`)
- Ethernet (RTL8111)
- Audio (AppleALC, `alcid=55`)
- Battery, keyboard and trackpad
- Bluetooth (after the standard Realtek Bluetooth stack)
- Wi-Fi **after** adding the Apple legacy IO80211 stack (see `docs/WIFI.md`)

**Known issues**

- Wi-Fi can disconnect after a while: the AP sends a deauthentication
  (`reason 6`). Test a WPA2-only network and disable WPA3/PMF/802.11r first.
- GPU power-well panic: `PG2 power well fuse distribution failed` in
  `AppleIntelPowerWell`. Not a DVMT/stolen-memory issue. See `docs/GPU.md`.
- Sleep/wake is not fully validated.
- AWDL, AirDrop and Continuity are not supported by AirPort_RTW88.
- iServices require **your own** generated SMBIOS (see below).

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
