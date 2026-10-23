# Formata crash fix (Steam app 580040)

Fixes the "random" crash in **Formata** where the game dies roughly a minute after
launch (in the menu or mid-match), on both Windows and Linux/Proton/Steam Deck.

## TL;DR

**Linux / Steam Deck / Proton** – Steam → right-click Formata → Properties →
General → Launch Options:

```
OPENSSL_ia32cap=:~0x20000000 %command%
```

**Windows** – run [`windows/apply-fix.bat`](windows/apply-fix.bat) once (or add a
user environment variable `OPENSSL_ia32cap` = `:~0x20000000` by hand), then
restart Steam. [`windows/remove-fix.bat`](windows/remove-fix.bat) undoes it.

## What's actually going wrong

Formata is built on Unreal Engine 4.17, which ships an old OpenSSL. That OpenSSL
has a hardware-accelerated SHA-1 routine using the CPU's SHA extensions
(`sha1rnds4` / `sha1nexte`). On CPUs that have SHA extensions – Intel 11th gen
(Rocket Lake) and newer, AMD Ryzen, etc. – the routine's epilogue restores XMM
registers with `movaps` from a misaligned address and faults:

```
EXCEPTION_ACCESS_VIOLATION at Formata-Win64-Shipping.exe+0x60E63
  movaps -0x48(%rax),%xmm6      ; rax = ...d7c (not 16-byte aligned)
```

The game hits this code periodically, which is why it looks random but tends to
happen about 60 seconds in.

`OPENSSL_ia32cap=:~0x20000000` clears CPUID leaf 7 EBX bit 29 (SHA) for OpenSSL
only, so it falls back to the plain software SHA-1 path. Nothing else in the game
or system is affected, and no game files are modified.

You are affected if your CPU supports SHA extensions (Linux: `grep -o sha_ni /proc/cpuinfo`).

## Verification

Tested on an Intel i9-11900KF, RTX 3060, Proton Experimental (11.0), build 2449161:

| Run | Result |
| --- | --- |
| without fix | crashed with the access violation above after ~60 s, every time |
| with fix | ran the full 5-minute test window with no crash |

The Windows `.bat` uses the same variable, which is the standard workaround for
this OpenSSL bug in old UE4 games on native Windows, but it was not tested on
native Windows here. Reports welcome via issues.
