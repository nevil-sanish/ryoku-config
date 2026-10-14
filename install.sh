#!/usr/bin/env bash
# install.sh: apply this Ryoku setup to the current user.
#   ./install.sh             configs + plugins
#   ./install.sh --packages  also install pkglist-repo.txt with pacman first
# Every ~/.config entry it overwrites is backed up first.
set -euo pipefail
cd "$(dirname "$0")"

command -v ryoku >/dev/null || { echo "ryoku not found: run this on a Ryoku system" >&2; exit 1; }

if [ "${1:-}" = "--packages" ]; then
	sudo pacman -S --needed - < pkglist-repo.txt
fi

# back up only what this repo is about to replace
backup="$HOME/.ryoku-config-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup/config"
for entry in config/*; do
	name=$(basename "$entry")
	[ -e "$HOME/.config/$name" ] && cp -a "$HOME/.config/$name" "$backup/config/"
done
[ -e "$HOME/.bashrc" ] && cp -a "$HOME/.bashrc" "$backup/"
echo "backup: $backup"

cp -a config/. "$HOME/.config/"
cp home/.bashrc "$HOME/.bashrc"

# plugins must go through the installer: Ryoku ignores folders copied by hand
for p in plugins/*/; do
	ryoku plugin add "$p" --yes
done

ryoku reload
echo "done. Turn widgets on from the Hub (Widgets / Plugins)."
