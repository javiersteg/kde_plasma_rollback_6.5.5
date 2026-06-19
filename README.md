# KDE Plasma 6.5.5 Rollback

## What broke

After a routine `apt upgrade` on KDE Neon (Ubuntu 24.04 Noble base), KDE Plasma was updated from **6.5.5 to 6.7.0**. The system runs a **DisplayLink dock** (evdi kernel module) alongside an AMD GPU, which means the kernel exposes multiple DRM devices at boot (`/dev/dri/card0`, `card1`, `card2`).

In KWin 6.7.0, a regression was introduced in how the compositor selects the primary DRM device. Instead of picking the AMD GPU (`amdgpu` driver), KWin was selecting the **evdi virtual display adapter** as `card0` (the primary GPU). Since evdi does not support Atomic Mode Setting (AMS) the way KWin 6.7.0 expects, the compositor failed to initialize properly, resulting in:

- Black screen or broken compositing on Wayland session startup
- `kscreen` applet failing to load: `org.kde.kscreen package does not exist`
- `libPlasma.so.6` not found errors due to mixed package versions after partial downgrade attempts
- KWin logging errors about no valid DRM output being found

## Why we rolled back instead of patching

The obvious fix would have been a udev rule to force `amdgpu` to always be `card0`, or setting `KWIN_DRM_DEVICES` to point at the correct device. However, by the time the issue was diagnosed, several manual downgrade attempts had left the system in an inconsistent state with packages at mixed versions (some at 6.5.5, some at 6.7.0, some dependencies unresolved).

Given the instability of the intermediate state and the fact that **KDE Neon caches previous package versions in `/var/cache/apt/archives/`**, the cleanest and fastest path to a working desktop was a full rollback to 6.5.5 — the last known good version — using the cached `.deb` files.

## What the script does

`rollback.sh` automates the full recovery process:

1. Disables the Neon repository so `apt` cannot pull 6.7.0 packages to resolve dependencies
2. Copies all 6.5.5 cached `.deb` files to a local directory
3. Installs the full set of KWin + Plasma packages from local files using `--allow-downgrades`
4. Applies `apt-mark hold` to prevent automatic re-upgrade to 6.7.0

## Requirements

- KDE Neon (Ubuntu 24.04 Noble base)
- 6.5.5 packages still present in `/var/cache/apt/archives/` (they are kept by default unless you ran `apt clean`)

## Usage

```bash
chmod +x rollback.sh
./rollback.sh
sudo reboot
```

## Notes

- The Neon repository stays disabled after running the script. Re-enable it manually once KDE 6.7.x ships a fix for the evdi/DRM device selection issue.
- Tested on a Slimbook with AMD GPU + DisplayLink dock (evdi 1.x).
