#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="git@github.com:you/dotfiles.git"   # <-- change to your actual repo

# -----------------------------------------------------------------------
# 1. Dotfiles: clone bare repo, force checkout (backing up any conflicts)
# -----------------------------------------------------------------------
echo "=== 1. Dotfiles ==="
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

dotfiles() { git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }

BACKUP_DIR="$HOME/.dotfiles-conflict-backup-$(date +%Y%m%d-%H%M%S)"

# Ask git which files would conflict, without touching anything yet
CONFLICTS=$(dotfiles checkout 2>&1 | grep -oP '^\s+\K.*' || true)

if [ -n "$CONFLICTS" ]; then
    echo "Conflicting files found — backing up to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    while IFS= read -r file; do
        [ -e "$HOME/$file" ] && mkdir -p "$BACKUP_DIR/$(dirname "$file")" && mv "$HOME/$file" "$BACKUP_DIR/$file"
    done <<< "$CONFLICTS"
else
    echo "No conflicts detected."
fi

dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
echo "Dotfiles checked out. Any overwritten originals are in: $BACKUP_DIR"

# -----------------------------------------------------------------------
# 2. Pacman packages
# -----------------------------------------------------------------------
echo "=== 2. Pacman packages ==="
if [ -f "$HOME/packages/pacman-explicit.txt" ]; then
    sudo pacman -S --needed - < "$HOME/packages/pacman-explicit.txt"
else
    echo "WARNING: $HOME/packages/pacman-explicit.txt not found — skipping."
fi

# -----------------------------------------------------------------------
# 3. AUR packages (requires yay)
# -----------------------------------------------------------------------
echo "=== 3. AUR packages ==="
if [ -f "$HOME/packages/pacman-aur.txt" ]; then
    if ! command -v yay &>/dev/null; then
        echo "yay not found — building from AUR..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
    fi
    yay -S --needed - < "$HOME/packages/pacman-aur.txt"
else
    echo "WARNING: $HOME/packages/pacman-aur.txt not found — skipping."
fi

# -----------------------------------------------------------------------
# 4. Flatpak
# -----------------------------------------------------------------------
echo "=== 4. Flatpak ==="
if command -v flatpak &>/dev/null; then
    if [ -f "$HOME/packages/flatpak-remotes.txt" ]; then
        while read -r remote_line; do
            name=$(echo "$remote_line" | awk '{print $1}')
            url=$(echo "$remote_line" | awk '{print $2}')
            [ -n "$name" ] && [ -n "$url" ] && flatpak remote-add --if-not-exists "$name" "$url"
        done < <(tail -n +2 "$HOME/packages/flatpak-remotes.txt")  # skip header row
    fi

    if [ -f "$HOME/packages/flatpak-apps.txt" ]; then
        flatpak install -y flathub $(cat "$HOME/packages/flatpak-apps.txt")
    else
        echo "WARNING: $HOME/packages/flatpak-apps.txt not found — skipping."
    fi
else
    echo "flatpak not installed — skipping."
fi

# -----------------------------------------------------------------------
# 5. /etc configuration (risky — always overwrites, no diffing)
# -----------------------------------------------------------------------
echo "=== 5. /etc configuration ==="
if [ -f "$HOME/etc-backup/pacman.conf" ]; then
    sudo cp "$HOME/etc-backup/pacman.conf" /etc/pacman.conf
    echo "Restored /etc/pacman.conf"
fi

if [ -f "$HOME/etc-backup/mkinitcpio.conf" ]; then
    sudo cp "$HOME/etc-backup/mkinitcpio.conf" /etc/mkinitcpio.conf
    echo "Restored /etc/mkinitcpio.conf — regenerating initramfs"
    sudo mkinitcpio -P
fi

# -----------------------------------------------------------------------
# 6. GRUB kernel parameter check (warn only, never auto-edit bootloader)
# -----------------------------------------------------------------------
echo "=== 6. GRUB kernel parameter check ==="
if [ -f /etc/default/grub ]; then
    if ! grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
        echo "WARNING: nvidia_drm.modeset=1 missing from /etc/default/grub."
        echo "Add it to GRUB_CMDLINE_LINUX_DEFAULT manually, then run:"
        echo "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
    else
        echo "nvidia_drm.modeset=1 already present."
    fi
else
    echo "/etc/default/grub not found — skipping GRUB check."
fi

echo "=== Done. Reboot to apply kernel/initramfs/driver changes. ==="
