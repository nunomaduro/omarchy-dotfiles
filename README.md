<h1 align="center">omarchy-dotfiles</h1>

<p align="center">The things I do after I install <a href="https://omarchy.org">Omarchy</a>, in one command.</p>

<p align="center">
  <img src="https://img.shields.io/badge/omarchy-aarch64-black?style=flat-square" alt="Omarchy on aarch64">
  <img src="https://img.shields.io/badge/shell-bash-black?style=flat-square" alt="Bash">
</p>

---

```bash
git clone https://github.com/nunomaduro/omarchy-dotfiles.git
cd omarchy-dotfiles
./install.sh
```

Open a new terminal. The machine is ready.

`install.sh` links each file under `home/` into `$HOME` with the same path, then runs `packages.sh`. You can run both scripts again: a step that is already done says so and moves on.

## Upgrade

```bash
./upgrade.sh
```

The alias `u` runs it from any folder. It pulls this repository, runs `install.sh` again for a file or an application that the repository gained, then updates what `omarchy update` does not reach: PhpStorm, `hod` and the Laravel installer. It ends with `omarchy update` for the system packages, the AUR packages and the mise tools, and with `mise prune` for each tool version that no configuration file names.

## What you get

### Mac shortcuts

`Super` works like `Cmd`. `Super + C` copies in Firefox and also in the terminal, because the binding sends `Ctrl + C` to an app and `Ctrl + Shift + C` to a terminal.

| Keys | Action |
| --- | --- |
| `Super + C` `V` `X` `Z` `A` | Copy, paste, cut, undo, select all |
| `Super + T` `W` `L` `R` | New tab, close tab, address bar, reload |
| `Super + Shift + [` `]` | Previous tab, next tab |
| `Super + ←` `→` `↑` `↓` | Line start, line end, document start, document end |
| `Alt + ←` `→` | Word left, word right |
| `Super + Backspace` | Delete to line start |
| `Alt + Backspace` | Delete word left |
| `Super + Q` | Close window |

The bindings live in [`home/.config/hypr/bindings.lua`](home/.config/hypr/bindings.lua).

### One theme, everywhere

Change the Omarchy theme and Firefox, Sublime Text and PhpStorm change with it. The hooks in [`home/.config/omarchy/hooks/theme-set.d/`](home/.config/omarchy/hooks/theme-set.d) give each app the colors of the theme:

- **Firefox** gets its colors from [Pywalfox](https://github.com/Frewacom/pywalfox), in light mode or dark mode to match the theme.
- **Sublime Text** gets a color scheme named `Omarchy`.
- **PhpStorm** gets a theme named `Omarchy`: the Islands look of PhpStorm, in the colors of the theme, for the window and the editor. Restart PhpStorm to see a new theme.

### Home folders

The folders in your home are lowercase: `~/downloads`, `~/documents`, `~/music`, `~/pictures`, `~/videos` and `~/projects`. A capitalized folder is renamed, and `~/Desktop`, `~/Templates` and `~/Public` are removed when they are empty.

### Firefox

Firefox becomes the default browser. A policy file installs Pywalfox and hides the Firefox account button and the extensions button.

### Git and GitHub

The GitHub CLI and GitHub Desktop are installed. If you have no SSH key, one is created. You type the passphrase of the key once in a session, and the SSH agent keeps the key until you log out. You log in to GitHub in the browser, and the key is added to your GitHub account.

### Docker

Docker, Buildx, Compose and lazydocker are installed, and the Docker socket starts the daemon on the first command. You are not in the `docker` group, so you run `sudo docker`.

### Claude

- **Claude Code** runs in auto mode, and the status line shows the model and how much of the context is used.
- **Voice input**: hold the key and talk.
- **Claude Desktop** is installed from the AUR.
- **[Herdr](https://github.com/herdrdev/herdr)** and **[Hod](https://github.com/hodstack/hodstack)** are installed too.

### PHP and Laravel

PHP, Composer and Node.js come from [mise](https://mise.jdx.dev), and the PHP builds come from [static-php-builds](https://github.com/nunomaduro/static-php-builds). The Laravel installer lands in `~/.local/bin`.

```
mise use php@8.4           # PHP 8.4 for this folder only
mise use --global php@8.5  # PHP 8.5 everywhere else
laravel new myproject
```

### Editors

- **PhpStorm** is downloaded for ARM64, checked against its checksum, and added to the app launcher. It opens with the file tree and the code, and nothing else: no toolbar, no status bar, no tabs, no tool window buttons.
- **Sublime Text** is installed from its own package source, with Package Control and a quiet set of preferences. `Super + T` opens Goto Anything, as `Cmd + T` does on a Mac.

### Terminal

- **[mise](https://mise.jdx.dev)** installs the newest release of a tool, with no wait after the release.
- **GeistMono Nerd Font** becomes the monospace font of the system.
- **[Starship](https://starship.rs)** shows the folder, the git branch and the exit code of the last failed command. Nothing else.

```
omarchy-dotfiles main ?
❯
```

- `w` takes you to `~/work`.

## Layout

```
.
├── install.sh     links home/ into $HOME, then runs packages.sh
├── packages.sh    installs the apps and the font
├── upgrade.sh     pulls this repository, then upgrades the machine
└── home/          each file, in the layout of $HOME
    ├── .bashrc
    ├── .claude/
    │   ├── hooks/
    │   └── settings.json
    └── .config/
        ├── herdr/
        ├── hypr/
        ├── mise/
        ├── omarchy/
        ├── starship.toml
        └── sublime-text/
```

## Make it yours

Fork the repository. Put a file in `home/` at the path it has under `$HOME`, add an install step to `packages.sh`, and run `./install.sh` again.

This repository is built for one machine: an Omarchy install on aarch64. Read it before you run it on yours. Your fingers may not want `Super + Q` to close a window.
