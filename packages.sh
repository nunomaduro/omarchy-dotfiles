#!/bin/bash

set -euo pipefail

echo "lowercasing the home folders..."
for entry in DOWNLOAD:downloads DOCUMENTS:documents MUSIC:music PICTURES:pictures VIDEOS:videos PROJECTS:projects DESKTOP: TEMPLATES: PUBLICSHARE:; do
  key="${entry%%:*}"
  target="$HOME/${entry#*:}"
  current="$(xdg-user-dir "$key")"
  current="${current%/}"
  target="${target%/}"

  if [ "$current" != "$target" ] && [ "$current" != "$HOME" ] && [ -d "$current" ]; then
    if [ "$target" = "$HOME" ]; then
      rmdir "$current" 2>/dev/null || echo "keeping $current because it is not empty"
    elif [ -e "$target" ]; then
      rmdir "$current" 2>/dev/null || echo "keeping $current because $target already exists"
    else
      mv "$current" "$target"
    fi
  fi

  mkdir -p "$target"
  xdg-user-dirs-update --set "$key" "$target"
done

echo "lowercasing the file manager bookmarks..."
bookmarks="$HOME/.config/gtk-3.0/bookmarks"
if [ -f "$bookmarks" ]; then
  for folder in downloads documents music pictures videos projects; do
    sed -i -E "s|^file://$HOME/$folder( .*)?$|file://$HOME/$folder|I" "$bookmarks"
  done
fi

if grep -Eq '^-(auth|password) .*pam_gnome_keyring\.so' /etc/pam.d/sddm; then
  echo "stopping the sddm password login from creating a login keyring..."
  sudo sed -i '/-auth.*pam_gnome_keyring\.so/d; /-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
else
  echo "sddm password login already creates no login keyring"
fi

echo "installing firefox..."
sudo pacman -S --needed --noconfirm firefox

if [ "$(env -u BROWSER xdg-settings get default-web-browser)" = "firefox.desktop" ]; then
  echo "firefox already the default browser"
else
  echo "setting firefox as the default browser..."
  env -u BROWSER xdg-settings set default-web-browser firefox.desktop
fi

echo "writing the firefox policies..."
sudo mkdir -p /etc/firefox/policies
sudo tee /etc/firefox/policies/policies.json >/dev/null <<'POLICIES'
{
  "policies": {
    "IPProtectionAvailable": false,
    "ExtensionSettings": {
      "pywalfox@frewacom.org": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/pywalfox/latest.xpi"
      }
    },
    "Preferences": {
      "identity.fxaccounts.toolbar.enabled": {
        "Value": false,
        "Status": "locked"
      },
      "extensions.unifiedExtensions.button.always_visible": {
        "Value": false,
        "Status": "locked"
      }
    }
  }
}
POLICIES

echo "installing pywalfox..."
yay -S --needed --noconfirm python-pywalfox

echo "installing herdr..."
yay -S --needed --noconfirm herdr-bin

echo "installing github desktop..."
yay -S --needed --noconfirm github-desktop-bin

echo "installing docker..."
sudo pacman -S --needed --noconfirm docker docker-buildx docker-compose lazydocker

if systemctl is-enabled docker.socket >/dev/null 2>&1; then
  echo "docker socket already enabled"
else
  echo "enabling the docker socket..."
  sudo systemctl enable --now docker.socket
fi

if command -v gh >/dev/null 2>&1; then
  echo "github cli already installed"
else
  echo "installing github cli..."
  omarchy-mise-install gh
fi

SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  echo "ssh key already exists"
else
  echo "creating the ssh key..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -f "$SSH_KEY"
fi

if systemctl --user is-enabled ssh-agent.socket >/dev/null 2>&1; then
  echo "ssh agent already enabled"
else
  echo "enabling the ssh agent..."
  systemctl --user enable --now ssh-agent.socket
fi

if gh auth status --hostname github.com >/dev/null 2>&1; then
  echo "github cli already logged in"
else
  echo "logging in to github..."
  gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key --scopes admin:public_key
fi

if gh ssh-key list 2>/dev/null | grep -Fq "$(cut -d' ' -f2 "$SSH_KEY.pub")"; then
  echo "ssh key already on github"
else
  echo "adding the ssh key to github..."
  gh ssh-key add "$SSH_KEY.pub" --title "$(uname -n)"
fi

if command -v hod >/dev/null 2>&1; then
  echo "hod already installed"
else
  echo "installing hod..."
  curl -fsSL https://github.com/hodstack/hodstack/releases/latest/download/install.sh | sh
fi

if command -v claude >/dev/null 2>&1; then
  echo "claude code already installed"
else
  echo "installing claude code..."
  omarchy-mise-install claude
fi

if pacman -Q claude-desktop >/dev/null 2>&1; then
  echo "claude desktop already installed"
else
  echo "installing claude desktop..."
  tmp="$(mktemp -d)"
  git clone --quiet https://aur.archlinux.org/claude-desktop.git "$tmp/claude-desktop"
  (cd "$tmp/claude-desktop" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

if mise where php >/dev/null 2>&1 && mise where node >/dev/null 2>&1 && [ -x "$HOME/.local/bin/laravel" ]; then
  echo "php, node and the laravel installer already installed"
else
  echo "installing php, node and the laravel installer..."
  omarchy-install-dev-env laravel
fi

if [ -x "$HOME/.cargo/bin/rustup" ]; then
  echo "rust already installed"
else
  echo "installing rust..."
  omarchy-install-dev-env rust
fi

PHPSTORM_HOME="$HOME/.local/phpstorm"

if [ -x "$PHPSTORM_HOME/bin/phpstorm" ]; then
  echo "phpstorm already installed"
else
  echo "installing phpstorm..."
  release="$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=PS&latest=true&type=release')"
  url="$(printf '%s' "$release" | jq -r '.PS[0].downloads.linuxARM64.link')"
  checksum_url="$(printf '%s' "$release" | jq -r '.PS[0].downloads.linuxARM64.checksumLink')"

  tmp="$(mktemp -d)"
  curl -fSL -o "$tmp/phpstorm.tar.gz" "$url"

  expected="$(curl -fsSL "$checksum_url" | cut -d' ' -f1)"
  actual="$(sha256sum "$tmp/phpstorm.tar.gz" | cut -d' ' -f1)"

  if [ "$expected" != "$actual" ]; then
    echo "the download of phpstorm does not match its checksum at $checksum_url"
    echo "delete $tmp and run ./packages.sh again"
    exit 1
  fi

  mkdir -p "$PHPSTORM_HOME"
  tar -xzf "$tmp/phpstorm.tar.gz" -C "$PHPSTORM_HOME" --strip-components=1
  rm -rf "$tmp"

  mkdir -p "$HOME/.local/bin"
  ln -sfn "$PHPSTORM_HOME/bin/phpstorm" "$HOME/.local/bin/phpstorm"

  mkdir -p "$HOME/.local/share/applications"
  cat > "$HOME/.local/share/applications/phpstorm.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=PhpStorm
Comment=Lightweight and Smart PHP IDE
Icon=$PHPSTORM_HOME/bin/phpstorm.svg
Exec=$PHPSTORM_HOME/bin/phpstorm %f
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-phpstorm
StartupNotify=true
EOF
fi

if pacman -Q sublime-text >/dev/null 2>&1; then
  echo "sublime text already installed"
else
  echo "installing sublime text..."
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/sublimehq-pub.gpg" https://download.sublimetext.com/sublimehq-pub.gpg
  sudo pacman-key --add "$tmp/sublimehq-pub.gpg"
  sudo pacman-key --lsign-key 8A8F901A
  rm -rf "$tmp"

  if ! grep -q "^\\[sublime-text\\]" /etc/pacman.conf; then
    printf '\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/aarch64\n' | sudo tee -a /etc/pacman.conf >/dev/null
  fi

  sudo pacman -Sy --needed --noconfirm sublime-text
fi

SUBLIME_INSTALLED="$HOME/.config/sublime-text/Installed Packages"
SUBLIME_PACKAGES="$HOME/.config/sublime-text/Packages"

if [ -f "$SUBLIME_INSTALLED/Package Control.sublime-package" ]; then
  echo "package control already installed"
else
  echo "installing package control..."
  mkdir -p "$SUBLIME_INSTALLED"
  curl -fsSL -o "$SUBLIME_INSTALLED/Package Control.sublime-package" \
    'https://packagecontrol.io/Package%20Control.sublime-package'
fi

FONT="GeistMono Nerd Font"

if fc-list : family | grep -Fq "$FONT"; then
  echo "$FONT already installed"
else
  echo "installing $FONT..."
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/GeistMono.tar.xz" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/GeistMono.tar.xz
  mkdir -p "$HOME/.local/share/fonts/GeistMono"
  tar -xf "$tmp/GeistMono.tar.xz" -C "$HOME/.local/share/fonts/GeistMono"
  rm -rf "$tmp"
  fc-cache -f "$HOME/.local/share/fonts"
fi

if command -v omarchy >/dev/null 2>&1 && [ "$(omarchy font current 2>/dev/null)" != "$FONT" ]; then
  echo "setting $FONT as the system monospace font..."
  omarchy font set "$FONT"
fi

if command -v omarchy >/dev/null 2>&1; then
  echo "applying the omarchy theme to firefox, sublime text and phpstorm..."
  omarchy theme set "$(omarchy theme current)"
fi
