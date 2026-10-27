# Hardware

## Machine

| Component | Detail |
| --- | --- |
| Laptop | HP 240 G8 (only machine tested) |
| CPU | Intel Core i3-1115G4 (Tiger Lake, 2 cores / 4 threads, 3.00 GHz) |
| iGPU | Intel UHD Graphics, device ID `0x9A78`, 1536 MB dynamic VRAM, Metal 2 |
| RAM | 16 GB (2x 8 GB DDR4 2667 MHz) |
| Storage | ADATA LEGEND 710 256 GB NVMe, `Revision VC0S036P` (only drive tested; other NVMe models untested and may behave differently) |
| Display | 1366x768 eDP |
| Wi-Fi | Realtek RTL8822CE, `10EC:C822` / `10EC:C82F` |
| Ethernet | Realtek RTL8111/8168H, `10EC:8168` |
| Audio | Realtek ALC (AppleALC, layout `55`) |
| Input | VoodooI2C + VoodooPS2 |
| SMBIOS | `MacBookPro16,2` (`Mac-5F9802EFE386AA28`) |

## PCI paths

| Device | PciRoot |
| --- | --- |
| iGPU | `PciRoot(0x0)/Pci(0x2,0x0)` |
| Wi-Fi (root port 1D.0) | `PciRoot(0x0)/Pci(0x1d,0x0)/Pci(0x0,0x0)` |
| Ethernet (root port 1D.1) | `PciRoot(0x0)/Pci(0x1d,0x1)/Pci(0x0,0x0)` |

The iGPU uses `AAPL,ig-platform-id = 0x9A490000` (`0000499a` as Data).

## BIOS / UEFI

| Setting | Value |
| --- | --- |
| DVMT Pre-Allocated | 256 MB (96 MB works) |
| CFG Lock | Disabled |
| Secure Boot | Off |
| Fast Boot | Off |
| VT-d | Per OpenCore `DisableIoMapper` |

## Software tested

| Component | Version |
| --- | --- |
| macOS | Sequoia 15.8.1 (24H32) |
| OpenCore | 1.0.8 DBG (`DBG-108-2026-09-27`) |
| Lilu | 1.7.2 |
| VirtualSMC | 1.3.8 |
| SMCBatteryManager | 1.3.8 |
| AppleALC | 1.9.8 |
| NVMeFix | 1.1.3 |
| BlueToolFixup | 2.7.2 |
| VoodooI2C | 2.9.1 |
| VoodooI2CHID | 1.0 |
| VoodooPS2Controller | 2.3.7 |
| RealtekRTL8111 | 2.4.2 |
| AMFIPass | 1.4.1 |
| WhateverXe | 0.6.0 |
| AirPort_RTW88 | 2.0.1 |

## Notes

- `IOFBMemorySize` reports **256 MB**; no `-igfxdvmt` or
  `framebuffer-stolenmem` is needed.
- `SSDT-PNLF` provides internal-display brightness.
- The Wi-Fi legacy stack (`IOSkywalkFamily`, `IO80211FamilyLegacy`) is Apple
  property and is not included; see `docs/WIFI.md`.
- The Tiger Lake graphics kexts/bundles live in `/Library/Extensions` and
  `/Library/GPUBundles`, installed by the WhateverXe Graphics package; they are
  not part of the EFI.
