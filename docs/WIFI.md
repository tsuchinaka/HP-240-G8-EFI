# Wi-Fi: RTL8822CE + AirPort_RTW88

## Driver

| Item | Value |
| --- | --- |
| Adapter | Realtek RTL8822CE (`10EC:C822`, `10EC:C82F`) |
| Driver | AirPort_RTW88 2.0.1 (`com.rtw88.airport`) |
| Architecture | Native AirPort/IO80211, not Feixiao |
| Control | macOS Wi-Fi menu / CoreWLAN |

This is **not** Feixiao, so `rtw88ctl` and Starskiff do not apply. There is no
separate connection app: networks appear in the macOS Wi-Fi menu.

## Required Apple legacy stack (not included)

On Sonoma 14.4 and later the driver needs the legacy networking components:

- `IOSkywalkFamily.kext`
- `IO80211FamilyLegacy.kext` (and its `AirPortBrcmNIC.kext` plugin)

These are Apple property and are **not** distributed in this repository.
Obtain them from the official AirPort_RTW88 instructions or from
<https://github.com/Edwardwich/BCM-WIFI-Sequoia>, then copy them into
`EFI/OC/Kexts`.

`AirPort_RTW88.kext` 2.0.1 is included under its own license, but its
`Kernel > Add` entry is **disabled** until the legacy stack is present.

Enable these entries in `Kernel > Add` after copying the files:

| BundlePath | MinKernel | Enabled |
| --- | --- | --- |
| `IOSkywalkFamily.kext` | `22.0.0` | yes |
| `IO80211FamilyLegacy.kext` | `22.0.0` | yes |
| `IO80211FamilyLegacy.kext/Contents/PlugIns/AirPortBrcmNIC.kext` | `22.0.0` | yes |
| `AirPort_RTW88.kext` | `22.0.0` | yes |

Do not add `HS80211Family.kext` or `Realtek88LegacyAirport.kext`; those are for
Mojave/Catalina/Big Sur and are not used on Sequoia.

## Known issue: the AP deauthenticates (`reason 6`)

A common symptom is: the network connects, works for a while, and then drops.
The driver telemetry shows:

```text
STA_LAST_DISCONNECT_SOURCE = "ap-deauth-or-disassoc"
STA_DEAUTH_REASON          = 6
```

Reason 6 is *"Class 2 frame received from nonauthenticated STA"*. The AP is
ending the session, usually because of an authentication/security mismatch, not
because the kext crashed.

Test in this order:

1. **WPA2-PSK (AES/CCMP) only** on the AP. Disable WPA3 and WPA2/WPA3
   transition mode. AirPort_RTW88 has only partial WPA3.
2. Disable **PMF / 802.11w**, **802.11r / Fast Roaming**, and **band steering**.
3. **Private Wi-Fi Address = Off** for the network, and forget/rejoin it.
4. Test **5 GHz** and **2.4 GHz** separately.
5. On 2.4 GHz, disable Bluetooth and see whether the drops stop (BT coexistence).
6. If you do not use AirDrop, test with AWDL down:
   `sudo ifconfig awdl0 down`.

The cache/driver does not expose country, antenna, BT-coexistence or power-save
tweaks. Those are internal to the driver.

## Not supported

- Full WPA3 (partial implementation only)
- AWDL, AirDrop, Handoff, Universal Clipboard
- 6 GHz
- USB and SDIO Realtek adapters

## Verify

```sh
system_profiler SPAirPortDataType | grep -iE "Card Type|Firmware|Status|Current Network|Channel|Signal"
kextstat | grep -iE "AirportRTW88|IO80211FamilyLegacy|IOSkywalk"
```

The expected firmware string is `RTL8822CE (AirPort_RTW88 2.0.1)`.
