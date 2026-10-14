# ryoku-config

My Ryoku desktop setup (Hyprland + Quickshell on Arch):
theme, bar, launcher, hub, keybinds, animations, terminal and app colours,
plus the desktop widget plugins I use. Clone it to get the same look and feel.

Pairs with [ryoku-things](https://github.com/nevil-sanish/ryoku-things)
(Google Tasks / Calendar / Docs and Circle to Search widgets).

## Contents

| Path                         | Goes to                          |
| ---------------------------- | -------------------------------- |
| `config/`                    | `~/.config/`                     |
| `local-share-ryoku/plugins/` | `~/.local/share/ryoku/plugins/`  |
| `home/.bashrc`               | `~/.bashrc`                      |
| `pkglist-repo.txt`           | packages from the official repos |
| `pkglist-aur.txt`            | packages from the AUR            |

## Install (on a Ryoku / RyokuArch system)

**Back up your own config first**, the copy step overwrites matching files:

```sh
cp -a ~/.config ~/.config.before-ryoku-config
```

Then:

```sh
git clone https://github.com/nevil-sanish/ryoku-config
cd ryoku-config
sudo pacman -S --needed - < pkglist-repo.txt
yay -S --needed - < pkglist-aur.txt     # optional, these are my extra apps
cp -a config/. ~/.config/
cp -a local-share-ryoku/plugins ~/.local/share/ryoku/
cp home/.bashrc ~/
ryoku reload
```

Only want the look? Copy just the parts you like, e.g. `config/hypr`,
`config/quickshell`, `config/ryoku`, `config/matugen`, `config/kitty`.

## Not included (on purpose)

- Monitor layout: Ryoku regenerates `~/.config/hypr/monitors.lua` for your own
  screens (set it in Ryoku Settings > Displays).
- Accounts and credentials of any kind: git identity, GitHub/gcloud logins,
  Google widget sign-in, browser profiles. Set your own up.
- Machine state: dconf database, GTK bookmarks, fish universal variables.

## Credits

Ryoku and its shell are by the Ryoku project. Plugins under
`local-share-ryoku/plugins/` keep their original authors and licenses (see each
plugin's `manifest.json` / `PROVENANCE.md`).
