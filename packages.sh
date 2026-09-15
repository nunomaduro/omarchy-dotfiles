#!/bin/bash

set -euo pipefail

echo "installing firefox..."
sudo pacman -S --needed --noconfirm firefox

if [ "$(env -u BROWSER xdg-settings get default-web-browser)" = "firefox.desktop" ]; then
  echo "firefox already the default browser"
else
  echo "setting firefox as the default browser..."
  env -u BROWSER xdg-settings set default-web-browser firefox.desktop
fi

if command -v zed >/dev/null 2>&1; then
  echo "zed already installed"
else
  echo "installing zed..."
  curl -fsSL https://zed.dev/install.sh | sh
fi

echo "installing herdr..."
yay -S --needed --noconfirm herdr-bin

echo "installing github desktop..."
yay -S --needed --noconfirm github-desktop-bin

if command -v hod >/dev/null 2>&1; then
  echo "hod already installed"
else
  echo "installing hod..."
  curl -fsSL https://github.com/hodstack/hodstack/releases/latest/download/install.sh | sh
fi

echo "installing lerd prerequisites..."
sudo pacman -S --needed --noconfirm crun nss

if command -v lerd >/dev/null 2>&1; then
  echo "lerd already installed"
else
  echo "installing lerd..."
  curl -fsSL https://lerd.sh/install.sh | bash
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
