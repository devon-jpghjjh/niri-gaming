# d_ARK gaming tweaks: unlock RX 9000-series overclocking/undervolting and make sure LACT's daemon is running.

d_ark-tweaks:
    #!/usr/bin/bash
    set -euo pipefail
    echo "[d_ARK] appending amdgpu.ppfeaturemask=0xffffffff (skips if present)..."
    rpm-ostree kargs --append-if-missing="amdgpu.ppfeaturemask=0xffffffff"
    echo "[d_ARK] enabling lactd..."
    systemctl enable --now lactd
    echo "[d_ARK] done — reboot to apply the kernel argument, then configure profiles in LACT."

# Show the d_ARK system summary (image, session, GPU tools).
d_ark-info:
    #!/usr/bin/bash
    grep -E '^(PRETTY_NAME|LOGO)' /etc/os-release
    echo "GPU tools: $(command -v lact || echo 'lact MISSING')"
    echo "Sessions:  $(ls /usr/share/wayland-sessions/ 2>/dev/null | tr '\n' ' ')"
