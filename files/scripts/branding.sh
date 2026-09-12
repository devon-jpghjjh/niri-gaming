#!/usr/bin/env bash
set -euo pipefail

log() { echo "[d_ARK-branding] $*"; }

# --- 1. OS identity ---------------------------------------------------------
log "os-release identity:"
grep -E '^(NAME|PRETTY_NAME|LOGO|ID)=' /etc/os-release || true
if ! grep -q '^NAME=d_ARK' /etc/os-release; then
  log "WARN: NAME=d_ARK missing in /etc/os-release; fixing"
  sed -i 's/^NAME=.*/NAME=d_ARK/; s/^PRETTY_NAME=.*/PRETTY_NAME=d_ARK/; s/^LOGO=.*/LOGO=d_ARK-logo-icon/' /etc/os-release
fi
if [ -f /usr/lib/os-release ] && ! grep -q '^NAME=d_ARK' /usr/lib/os-release; then
  log "syncing d_ARK identity into /usr/lib/os-release"
  sed -i 's/^NAME=.*/NAME=d_ARK/; s/^PRETTY_NAME=.*/PRETTY_NAME=d_ARK/; s/^LOGO=.*/LOGO=d_ARK-logo-icon/' /usr/lib/os-release
fi
log "verified: $(grep '^PRETTY_NAME=' /etc/os-release)"

# --- 2. Plymouth ------------------------------------------------------------
PLY=/usr/share/plymouth/themes
LOGO=/usr/share/pixmaps/d_ARK-logo.png
base=""
cur="$(plymouth-set-default-theme 2>/dev/null || true)"
if [ -n "$cur" ] && [ -f "$PLY/$cur/$cur.plymouth" ]; then
  base="$cur"
fi
if [ -z "$base" ]; then
  for c in bazzite spinner bgrt; do
    if [ -f "$PLY/$c/$c.plymouth" ]; then base="$c"; break; fi
  done
fi
if [ -n "$base" ] && [ ! -d "$PLY/d_ARK" ]; then
  log "cloning plymouth theme '$base' -> d_ARK"
  cp -r "$PLY/$base" "$PLY/d_ARK"
  mv "$PLY/d_ARK/$base.plymouth" "$PLY/d_ARK/d_ARK.plymouth"
  sed -i "s|/themes/$base|/themes/d_ARK|g" "$PLY/d_ARK/d_ARK.plymouth"
  for img in watermark.png logo.png header-image.png; do
    [ -f "$PLY/d_ARK/$img" ] && cp "$LOGO" "$PLY/d_ARK/$img" && log "swapped $img"
  done
  if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    plymouth-set-default-theme d_ARK || true
    log "plymouth default theme = d_ARK"
  fi
else
  log "WARN: no plymouth base theme found (base='$base')"
fi

# --- 3. GRUB: distributor + d_ARK theme --------------------------------------
if [ -f /etc/default/grub ] && grep -q '^GRUB_DISTRIBUTOR=' /etc/default/grub; then
  sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="d_ARK"/' /etc/default/grub
else
  echo 'GRUB_DISTRIBUTOR="d_ARK"' >> /etc/default/grub
fi
THEME_DIR=/usr/share/grub/themes/d_ARK
if [ -f "$THEME_DIR/theme.txt" ]; then
  if grep -q '^GRUB_THEME=' /etc/default/grub; then
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="'"$THEME_DIR"'/theme.txt"|' /etc/default/grub
  else
    echo "GRUB_THEME=\"$THEME_DIR/theme.txt\"" >> /etc/default/grub
  fi
  TTF="$(fc-match -f '%{file}' 'DejaVu Sans Mono Bold' 2>/dev/null || true)"
  if [ -n "$TTF" ] && command -v grub2-mkfont >/dev/null 2>&1; then
    grub2-mkfont -s 22 -o "$THEME_DIR/d_ARK-22.pf2" "$TTF" 2>/dev/null || true
    grub2-mkfont -s 16 -o "$THEME_DIR/d_ARK-16.pf2" "$TTF" 2>/dev/null || true
    log "GRUB fonts generated from $TTF"
  fi
  log "GRUB theme configured at $THEME_DIR"
else
  log "WARN: $THEME_DIR/theme.txt missing; GRUB relabeled only"
fi

# --- 4. polkit agents: only system polkit + Noctalia's agent -----------------
leftover="$(rpm -qa | grep -iE 'polkit-(kde|gnome)' || true)"
if [ -n "$leftover" ]; then
  log "WARN: foreign polkit agents still present: $leftover"
else
  log "polkit ok: no kde/gnome polkit agents"
fi

# --- 5. icon cache ------------------------------------------------------------
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
log "done"
