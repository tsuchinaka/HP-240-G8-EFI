# AGENTS.md — instructions for AI assistants helping users install this EFI

This repo is an OpenCore EFI for an **HP 240 G8 (i3-1115G4, UHD 0x9A78,
RTL8822CE, ADATA LEGEND 710)** running macOS Sequoia 15.8.1. Help the user
adapt it to their machine. Do not break the rules below.

## 1. Never commit these

- Real SMBIOS values: `SystemSerialNumber`, `MLB`, `SystemUUID`, `ROM`,
  `ApECID`, any `mac-address` or MAC in `DeviceProperties`.
- Apple binaries, even if the user hands them to you: `IOSkywalkFamily.kext`,
  `IO80211FamilyLegacy.kext` (+ `AirPortBrcmNIC.kext`), `HS80211Family.kext`,
  `HfsPlus.efi`, `AppleIntelTGLGraphics*`, `AppleIntelTGLGraphicsFramebuffer`,
  `AppleIntelTGLGraphics*Driver.bundle`.
- `vault.plist` / `vault.sig`, `*.bak`, `*.img`, `opencore-*.txt`, `.Trashes`,
  `.DS_Store`, `._*`.

Placeholders that must stay in `config.plist`:

| Key | Placeholder |
| --- | --- |
| `SystemSerialNumber` | `C02XXXXXXXXX` |
| `MLB` | `00000000000000000` |
| `SystemUUID` | `00000000-0000-0000-0000-000000000000` |
| `ROM` | `000000000000` (Data, 6 zero bytes) |

## 2. Apple files: user-supplied only

Do **not** download Apple kexts, drivers or bundles from third-party mirrors,
and do not add them to git. If the install needs them:

1. Tell the user which files are missing and why (see `docs/WIFI.md`,
   `docs/GPU.md`, `docs/INSTALL.md`).
2. Ask the user to provide them **locally** from their own system or the
   official WhateverXe Graphics / AirPort_RTW88 / OpenCore instructions.
3. Apply them only to the user's local ESP copy, never to this repo.

`AirPort_RTW88.kext` is in the repo but its `Kernel > Add` entry stays
**disabled** until the user adds the Apple legacy stack locally.

## 3. Standard install flow for the user

1. Back up their ESP (`dd` image + file copy).
2. Generate their own SMBIOS with GenSMBIOS for `MacBookPro16,2`, plus
   `uuidgen` and their `en0` MAC as `ROM`. See `docs/INSTALL.md`.
3. Install WhateverXe Graphics pkg locally (Apple TGL stack).
4. User adds Apple legacy Wi-Fi stack locally; then enable the four disabled
   `Kernel > Add` entries (`IOSkywalkFamily`, `IO80211FamilyLegacy`,
   `AirPortBrcmNIC`, `AirPort_RTW88`).
5. Optional `HfsPlus.efi` only if their firmware needs HFS+; keep disabled
   otherwise.
6. Reset NVRAM from the OpenCore picker.

## 4. Machine differences

This EFI targets one board/BIOS. If the user's machine differs, re-check:
`SSDT-GPI0`/`SSDT-BATT` pinning, `USBPorts` map (not shipped), audio
`alcid`, DVMT Pre-Allocated (256 MB here; 60 MB needs the `docs/GPU.md`
workaround), and PCI paths in `docs/HARDWARE.md`.

## 5. Validate before every commit

```sh
plutil -lint EFI/OC/config.plist
./scripts/check-efi.sh
git status --short
```

Also grep for leaked identifiers before pushing:

```sh
grep -RIn -I -E 'C02DPGZFML7H|C02046102CDP8PGFB|82B3218B|905B9100' . --exclude-dir=.git
```

If anything matches, stop and sanitize.

## 6. What to tell the user

- Their real serial/MLB/UUID/ROM stay on their machine only.
- Wi-Fi drops are the main open issue (`reason 6`, see `docs/WIFI.md`).
  Debug with WPA2-only + no PMF/802.11r/band-steering first.
- Bluetooth and trackpad are confirmed working on the reference machine;
  sleep/wake is not fully validated.
