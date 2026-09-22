#!/bin/bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "${DOTFILES_UPGRADED:-}" ]; then
  echo "updating the dotfiles..."
  git -C "$DOTFILES" pull --ff-only
  exec env DOTFILES_UPGRADED=1 "$DOTFILES/upgrade.sh" "$@"
fi

PHPSTORM_HOME="$HOME/.local/phpstorm"

if [ -f "$PHPSTORM_HOME/product-info.json" ]; then
  installed="$(jq -r '.buildNumber' "$PHPSTORM_HOME/product-info.json")"
  latest="$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=PS&latest=true&type=release' | jq -r '.PS[0].build')"

  if [ "$installed" = "$latest" ]; then
    echo "phpstorm already the newest build"
  else
    echo "removing phpstorm $installed, because the newest build is $latest..."
    rm -rf "$PHPSTORM_HOME"
  fi
fi

"$DOTFILES/install.sh"

echo "updating hod..."
(cd "$DOTFILES" && hod update)

echo "updating the laravel installer..."
composer global update

omarchy update

echo "deleting the tool versions that no configuration file names..."
mise prune

echo
echo "the machine is upgraded"
