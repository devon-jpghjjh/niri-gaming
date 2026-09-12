#!/usr/bin/env bash
set -euo pipefail

log() { echo "[d_ARK-branding] $*"; }

# --- Plasma/KDE removal: leave a pure niri + Noctalia system ---------------
log "removing Plasma/KDE stack (sessions, apps, sddm, kde polkit agent)..."
dnf5 -y remove --skip-unavailable \
  plasma-desktop plasma-workspace kwin sddm sddm-breeze sddm-kcm \
  polkit-kde-agent-1 kdeplasma-addons dolphin konsole kate ark gwenview \
  okular spectacle kcalc krunner plasma-nm plasma-pa plasma-disks \
  plasma-systemmonitor kinfocenter kwalletmanager ksshaskpass

log "leftover plasma/kde packages after removal:"
rpm -qa | grep -iE '^(plasma|kwin|sddm|kde-)' | sort || true
log "leftover count: $(rpm -qa | grep -icE '^(plasma|kwin|sddm|kde-)' || true)"
