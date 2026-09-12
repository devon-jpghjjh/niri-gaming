# d_ARK &nbsp; [![build](https://github.com/devon-jpghjjh/niri-gaming/actions/workflows/build.yml/badge.svg)](https://github.com/devon-jpghjjh/niri-gaming/actions/workflows/build.yml) [![iso](https://github.com/devon-jpghjjh/niri-gaming/actions/workflows/iso.yml/badge.svg)](https://github.com/devon-jpghjjh/niri-gaming/actions/workflows/iso.yml)

**d_ARK** is a custom Fedora Atomic gaming image built with [BlueBuild](https://blue-build.org/)
on top of **[Bazzite](https://bazzite.gg/)** (not Silverblue/Fedora Workstation — the
upstream template README mentioned silverblue-main; this repo builds from
`ghcr.io/ublue-os/bazzite:stable`), with the **niri** scrollable-tiling compositor and
**Noctalia** shell as the desktop instead of Plasma, plus:

- greetd + **Noctalia Greeter** login screen (no SDDM), Noctalia's built-in polkit agent
- **LACT** + CoreCtrl (AMD GPU control for the RX 9070), `ujust d_ark-tweaks` applies the overclock karg
- **Faugus Launcher**, protontricks — on top of Bazzite's full gaming stack (Steam + Game Mode, Lutris, Heroic, ProtonUp-Qt, MangoHud, gamescope, controller drivers)
- Ghostty, yazi, micro, neovim, Brave Origin, KDE Connect
- Telegram + Bazaar as system flatpaks on first boot
- d_ARK branding: os-release identity, GRUB theme, Plymouth splash, wallpaper, fastfetch logo

## Installing

Flash the ISO from the [iso workflow artifacts](https://github.com/devon-jpghjjh/niri-gaming/actions/workflows/iso.yml)
(Ventoy works; it's a full offline installer, btrfs is the default automatic layout), or
rebase an existing atomic Fedora system:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/devon-jpghjjh/niri-gaming:latest
systemctl reboot
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/devon-jpghjjh/niri-gaming:latest
systemctl reboot
```

The ISO greeter is Noctalia Greeter; the desktop session is niri + Noctalia (Steam Game
Mode is listed as a session too).

> [!NOTE]
> On an immutable system `/` always shows as 100% full — that's the read-only composefs.
> Your files live in `/var/home`, which shares the disk with everything else.

## Verification

Images are signed with cosign. Verify with the `cosign.pub` in this repo:

```bash
cosign verify --key cosign.pub ghcr.io/devon-jpghjjh/niri-gaming
```

## Customizing

Edit `recipes/recipe.yml` (packages, modules) or `files/` (branding, configs, scripts),
push to `main`, and GitHub Actions rebuilds the image (~8 min, nightly) and can publish
a fresh ISO. Docs: [recipes](https://blue-build.org/reference/recipe/), [modules](https://blue-build.org/reference/module/).
