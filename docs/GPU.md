# Graphics: Tiger Lake UHD 0x9A78 + WhateverXe

## Stack

| Component | Version | Location |
| --- | --- | --- |
| WhateverXe | 0.6.0 RELEASE (`org.b00t0x.WhateverXe`) | `EFI/OC/Kexts` |
| AppleIntelTGLCompat | 0.5.0 (`org.b00t0x.AppleIntelTGLCompat`) | `/Library/Extensions` |
| AppleIntelTGLGraphics | 16.0.0 | `/Library/Extensions` |
| AppleIntelTGLGraphicsFramebuffer | 16.0.0 | `/Library/Extensions` |
| AMFIPass | 1.4.1 Mod | `EFI/OC/Kexts` |
| Lilu | 1.7.2 | `EFI/OC/Kexts` |

WhateverXe is a Lilu plugin derived from WhateverGreen. It adapts Apple's
Tiger Lake graphics drivers for the Intel Xe-LP iGPU. It is **not** a complete
standalone driver: the Apple TGL kexts and Metal/GL/VA bundles must come from
the signed WhateverXe Graphics package.

On the tested machine the installed receipts are
`org.b00t0x.WhateverXe.Sequoia` and `org.b00t0x.WhateverXe.Common`, both
version **0.2.0**. Graphics 0.3.x is not installed.

## Install the graphics package

- <https://github.com/b00t0x/WhateverXe-Graphics/releases>
- <https://github.com/b00t0x/WhateverXe/releases>

The package installs the Apple TGL kexts into `/Library/Extensions` and the
bundles into `/Library/GPUBundles`, then rebuilds the auxiliary kernel
collection. The EFI already contains `WhateverXe.kext` and `AMFIPass.kext`.

Rules:

- **Do not** load WhateverGreen and WhateverXe at the same time.
- Do not mix AMFIPass builds; use the Mod build linked from the WhateverXe
  Graphics repository.
- Do not use `-yTileDisable` with the Display 13 backend.
- `AAPL,GfxYTile` is not required; the backend selects Y tiling automatically.

## Boot arguments

Already in `config.plist`:

```text
-allow3d -disablegfxfirmware
```

Optional:

| Flag | Purpose |
| --- | --- |
| `gfxrst=0..4` | Boot framebuffer handoff (0 auto, 1 reset, 2 copy, 3 clear, 4 disable) |
| `-wexoff` | Disable WhateverXe (useful to isolate a graphics panic) |
| `-wexbeta` | Bypass the OS-version check |
| `-wex-tgl-off` | Disable the Tiger Lake path |
| `-wexdbg` | Debug logging, only effective in a DEBUG build |

`-wex-nopanel` was removed in 0.4.0; do not use it.

## DVMT and stolen memory

WhateverXe recommends **96 MB** or more of DVMT Pre-Allocated. This machine
reports:

```text
IOFBMemorySize = 268435456  (256 MB)
VRAM,totalMB   = 1536
```

That means the native stolen pool is already **256 MB** and no DVMT workaround
is needed.

If your BIOS is fixed at **60 MB**, add:

```text
-igfxdvmt
```

and set on the iGPU (`PciRoot(0x0)/Pci(0x2,0x0)`):

| Property | Type | Value |
| --- | --- | --- |
| `framebuffer-patch-enable` | Data | `01000000` |
| `framebuffer-stolenmem` | Data | `0000C003` |

`0000C003` is little-endian `0x03C00000` = 60 MB.

**Important:** WhateverXe only applies `framebuffer-stolenmem` when
`requested <= native pool` (`kern_xe.cpp`, `TGLStolenMemoryApplied`). It can
shrink or equal the pool, but it cannot raise it. To get 256 MB you must change
DVMT Pre-Allocated in the BIOS; setting `00000010` (256 MB) in a 60 MB system
is rejected.

If the native pool is already 256 MB, adding `framebuffer-stolenmem =
00000010` is a no-op.

## The PG2 power-well panic

A separate known failure is:

```text
panic: "[IGFB][PANIC][POWER_WEL] PG2 power well fuse distribution failed"
AppleIntelPowerWell::hwSetPowerWellStatePGE
```

This is a Tiger Lake display power-well sequencing failure in Apple's
`AppleIntelTGLGraphicsFramebuffer`, not a DVMT/stolen-memory problem. The
stolen-memory workaround will not fix it. To isolate it:

1. Boot with `-wexoff` and see whether the panic disappears.
2. Remove external displays/docks and test the internal panel only.
3. Report the panic to <https://github.com/b00t0x/WhateverXe/issues> with the
   panic log, device ID, macOS build and connector layout.

## Known limitations

- Reconnecting a monitor to a dedicated DisplayPort can leave the screen black
  or freeze the machine.
- Up to three displays; a fourth gets no image.
- Some image-conversion operations can crash the application.
- Safari video playback may drop frames.
- Full system sleep/wake and resolutions above the tested set are unverified.
- USB-C display output keeps part of the display hardware out of a low-power
  state.
