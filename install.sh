#!/bin/bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find "$DOTFILES/home" -type f -print0 | while IFS= read -r -d '' src; do
  target="$HOME/${src#"$DOTFILES/home/"}"

  mkdir -p "$(dirname "$target")"
  ln -sfn "$src" "$target"

  echo "linked ${target/#$HOME/\~}"
done

"$DOTFILES/packages.sh"

echo
echo "the dotfiles are installed"
echo "open a new terminal to load the shell aliases and the prompt"
