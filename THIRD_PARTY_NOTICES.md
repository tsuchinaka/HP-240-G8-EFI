# Third-party notices

This repository contains configuration, documentation and scripts released
under the MIT License (`LICENSE`), plus third-party binaries distributed under
their own licenses. The license texts collected here are in `LICENSES/`.

## Included components

| Component | Version | License | Source |
| --- | --- | --- | --- |
| OpenCore | 1.0.8 | BSD-3-Clause | https://github.com/acidanthera/OpenCorePkg |
| Lilu | 1.7.2 | BSD-3-Clause | https://github.com/acidanthera/Lilu |
| VirtualSMC | 1.3.8 | BSD-3-Clause | https://github.com/acidanthera/VirtualSMC |
| SMCBatteryManager | 1.3.8 | BSD-3-Clause | https://github.com/acidanthera/VirtualSMC |
| AppleALC | 1.9.8 | BSD-3-Clause | https://github.com/acidanthera/AppleALC |
| NVMeFix | 1.1.3 | See upstream | https://github.com/acidanthera/NVMeFix |
| BlueToolFixup | 2.7.2 | GPL-2.0 | https://github.com/acidanthera/BrcmPatchRAM |
| VoodooI2C | 2.9.1 | GPL-3.0 | https://github.com/VoodooI2C/VoodooI2C |
| VoodooI2CHID | 1.0 | GPL-3.0 | https://github.com/VoodooI2C/VoodooI2C |
| VoodooPS2Controller | 2.3.7 | See upstream | https://github.com/acidanthera/VoodooPS2 |
| VoodooInput | 1.1.6 | GPL-2.0 | https://github.com/acidanthera/VoodooInput |
| RealtekRTL8111 | 2.4.2 | See upstream | https://github.com/Mieze/RTL8111_driver_for_OS_X |
| RealtekBluetoothFirmware | 1.0.2 | See upstream | https://github.com/thegwchr/RealtekBluetoothFirmware |
| AMFIPass | 1.4.1 | See upstream | https://github.com/kaoskinkae/AMFIPass |
| WhateverXe | 0.6.0 | BSD-3-Clause | https://github.com/b00t0x/WhateverXe |
| AirPort_RTW88 | 2.0.1 | Realtek AirPort Family Project License 1.0 | https://github.com/xnoah222/Realtek-AirPort-Family |
| Realtek rtlwifi firmware | — | Realtek firmware license | https://github.com/xnoah222/Realtek-AirPort-Family |

The ACPI SSDTs are board-specific and derived from the Dortania/OpenCore
community documentation. Keep their upstream notices when redistributing.

## Not included

These components are **not** part of this repository:

- Apple `IOSkywalkFamily.kext`
- Apple `IO80211FamilyLegacy.kext` and `AirPortBrcmNIC.kext`
- Apple `HfsPlus.efi`
- Apple Tiger Lake graphics kexts and bundles
  (`AppleIntelTGLGraphics*`, `AppleIntelTGLGraphicsFramebuffer`,
  `AppleIntelTGLGraphics*Driver.bundle`)
- `SimpleHDA.kext`
- `USBPorts.kext`
- `HS80211Family.kext`
- `Realtek88LegacyAirport.kext`

Apple components remain Apple's property. Obtain them from the official
WhateverXe Graphics / AirPort_RTW88 / OpenCore sources and follow their terms.

## License texts

- `LICENSES/BSD-3-Clause.txt`
- `LICENSES/GPL-2.0.txt`
- `LICENSES/GPL-3.0.txt`
- `LICENSES/MIT.txt`
- `LICENSES/AirPort_RTW88.txt`
- `LICENSES/WhateverXe.txt`
- `LICENSES/rtlwifi_firmware.txt`

For components marked "See upstream", the authoritative license is in the
linked repository. If you redistribute a modified build, keep the upstream
copyright notices and source links.
