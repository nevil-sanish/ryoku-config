# ryoku-config

My Ryoku desktop setup (Hyprland + Quickshell on Arch): theme, bar, launcher,
hub, keybinds, animations, terminal and app colours, plus desktop widgets
including Google Tasks, Calendar, Docs and Circle to Search. Clone it to get
the same look and feel.

## Install (on a Ryoku / RyokuArch system)

```sh
git clone https://github.com/nevil-sanish/ryoku-config
cd ryoku-config
./install.sh              # configs + widgets
./install.sh --packages   # same, plus the pacman packages in pkglist-repo.txt
```

`install.sh` backs up every `~/.config` folder it replaces (and `~/.bashrc`) to
`~/.ryoku-config-backup/<date>/`, copies the configs, installs every widget with
`ryoku plugin add`, and reloads the desktop. Then turn widgets on and place them
from the Hub (**Widgets / Plugins**).

Only want part of the look? Copy single folders instead, e.g. `config/hypr`,
`config/quickshell`, `config/ryoku`, `config/matugen`, `config/kitty`. Extra apps
I use from the AUR are listed in `pkglist-aur.txt` (optional).

## Contents

| Path               | What                                         |
| ------------------ | -------------------------------------------- |
| `config/`          | goes to `~/.config/`                         |
| `home/.bashrc`     | goes to `~/.bashrc`                          |
| `plugins/`         | desktop widgets, installed by `install.sh`   |
| `pkglist-repo.txt` | packages from the official repos             |
| `pkglist-aur.txt`  | packages from the AUR (optional)             |

### Widgets

| Plugin               | What it does                                                    |
| -------------------- | --------------------------------------------------------------- |
| `google-tasks`       | Google Tasks default list: add tasks, click ○ to complete       |
| `google-calendar`    | Next events on your primary calendar; click to open, + new      |
| `google-docs`        | Recently edited Google Docs; + new doc, K opens Google Keep     |
| `mjw-todo`, `mjw-notes`, `mjw-habits` | Local to-do, notes and habit cards (by their original authors) |
| `bluetooth-profiles` | Bar glyph to switch Bluetooth audio profiles/codecs             |

> Google Keep has no public API for personal accounts, so notes go through Docs
> (the K button opens Keep in the browser).

## Google sign-in (Tasks, Calendar, Docs widgets)

The widgets use **your own** Google OAuth client. No keys ship in this repo.

1. Open <https://console.cloud.google.com/>, create a project.
2. **APIs & Services → Library**: enable **Google Tasks API**, **Google Calendar API**
   and **Google Drive API**.
3. **OAuth consent screen**: External, add your Google account as a **test user**.
4. **Credentials → Create credentials → OAuth client ID → Desktop app**, then
   **Download JSON**.
5. Save it as `~/.config/ryoku/google-client.json` (or point
   `RYOKU_GOOGLE_CLIENT` at it). Never commit this file.

The first time a widget loads, your browser opens for consent. Each widget asks
only for its own scope:

| Widget   | Scope                                                          |
| -------- | -------------------------------------------------------------- |
| Tasks    | `auth/tasks` (read + write tasks)                              |
| Calendar | `auth/calendar.readonly`                                       |
| Docs     | `auth/drive.metadata.readonly` (names/links only, not contents) |

Tokens are stored per widget in `~/.local/state/ryoku/plugins/<id>/token.json`
(mode 600). Delete that file to sign out.

## Circle to Search

Moved to its own repo: <https://github.com/nevil-sanish/circle-to-search-linux>
(Google Lens or Groq/Gemini/ChatGPT/Claude on any screen crop).

## What the widgets run, read and write

- `bin/gapi` (Python 3, stdlib only): OAuth on a `127.0.0.1` redirect, then
  HTTPS calls to `*.googleapis.com` only. Reads your client JSON, writes only
  its token file.

## Not included (on purpose)

- Monitor layout: Ryoku regenerates `~/.config/hypr/monitors.lua` for your own
  screens (Ryoku Settings > Displays).
- Accounts and credentials of any kind: git identity, GitHub/gcloud logins,
  Google sign-in, browser profiles. Set your own up.
- Machine state: dconf database, GTK bookmarks, fish universal variables.

## Credits

Ryoku and its shell are by the Ryoku project. Plugins under `plugins/` keep
their original authors and licenses (see each plugin's `manifest.json` /
`LICENSE` / `PROVENANCE.md`). The Google and Circle to Search widgets are MIT.
