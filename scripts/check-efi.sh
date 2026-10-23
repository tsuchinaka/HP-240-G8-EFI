#!/bin/sh
# Check that the EFI config is valid and still uses sanitized SMBIOS placeholders.
# Run from the repository root before committing.
set -eu

CFG="${1:-EFI/OC/config.plist}"

if [ ! -f "$CFG" ]; then
    echo "missing: $CFG" >&2
    exit 1
fi

echo "== plutil =="
plutil -lint "$CFG"

fail=0
check() {
    key="$1"
    want="$2"
    got=$(plutil -extract "$key" raw -o - "$CFG" 2>/dev/null || true)
    if [ "$got" != "$want" ]; then
        echo "WARNING: $key is not the placeholder '$want'" >&2
        echo "         current: $got" >&2
        fail=1
    fi
}

check PlatformInfo.Generic.SystemSerialNumber "C02XXXXXXXXX"
check PlatformInfo.Generic.MLB "00000000000000000"
check PlatformInfo.Generic.SystemUUID "00000000-0000-0000-0000-000000000000"

echo "== placeholders =="
echo "Serial: $(plutil -extract PlatformInfo.Generic.SystemSerialNumber raw -o - "$CFG")"
echo "MLB:    $(plutil -extract PlatformInfo.Generic.MLB raw -o - "$CFG")"
echo "UUID:   $(plutil -extract PlatformInfo.Generic.SystemUUID raw -o - "$CFG")"

if [ "$fail" -ne 0 ]; then
    echo "Do not commit your real SMBIOS values." >&2
    exit 1
fi

echo "OK: sanitized placeholders present"
