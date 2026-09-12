#!/usr/bin/env bash
set -euo pipefail

# d_ARK branding: plymouth theme, GRUB distributor, icon cache

PLYMOUTH_DIR=/usr/share/plymouth/themes
LOGO=/usr/share/pixmaps/d_ARK-logo.png

# --- Plymouth: clone an existing theme as "d_ARK" and swap in our logo ---
base_theme=""
for candidate in spinner bgrt; do
  if [ -f "$PLYMOUTH_DIR/$candidate/$candidate.plymouth" ]; then
    base_theme="$candidate"
    break
  fi
done
if [ -z "$base_theme" ] && command -v plymouth-set-default-theme >/dev/null 2>&1; then
  current="$(plymouth-set-default-theme 2>/dev/null || true)"
  if [ -n "$current" ] && [ -f "$PLYMOUTH_DIR/$current/$current.plymouth" ]; then
    base_theme="$current"
  fi
fi

if [ -n "$base_theme" ] && [ ! -d "$PLYMOUTH_DIR/d_ARK" ]; then
  cp -r "$PLYMOUTH_DIR/$base_theme" "$PLYMOUTH_DIR/d_ARK"
  mv "$PLYMOUTH_DIR/d_ARK/$base_theme.plymouth" "$PLYMOUTH_DIR/d_ARK/d_ARK.plymouth"
  # point the descriptor at the d_ARK directory
  sed -i "s|/themes/$base_theme|/themes/d_ARK|g" "$PLYMOUTH_DIR/d_ARK/d_ARK.plymouth"
  # swap the theme's logo/watermark images if present
  for img in watermark.png logo.png header-image.png; do
    if [ -f "$PLYMOUTH_DIR/d_ARK/$img" ]; then
      cp "$LOGO" "$PLYMOUTH_DIR/d_ARK/$img"
    fi
  done
  if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    plymouth-set-default-theme d_ARK || true
  fi
fi

# --- GRUB menu distributor name ---
if [ -f /etc/default/grub ] && grep -q '^GRUB_DISTRIBUTOR=' /etc/default/grub; then
  sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="d_ARK"/' /etc/default/grub
else
  echo 'GRUB_DISTRIBUTOR="d_ARK"' >> /etc/default/grub
fi

# --- refresh hicolor icon cache so d_ARK-logo-icon resolves everywhere ---
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
