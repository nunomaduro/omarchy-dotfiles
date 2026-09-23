# The intention of this project

This project holds the dotfiles of one Omarchy machine on aarch64. The owner of that machine runs it one time on a fresh install, thus the machine carries the configuration files, the applications and the font that Omarchy does not ship. It is an application, and no other developer installs it.

Set up the machine with `./install.sh`. That script links each file under `home/` into `$HOME` in the same layout, then runs `./packages.sh`, which installs Firefox, Docker, Herdr, Hod, the Claude Code CLI, the Claude desktop app, PHP, the Laravel installer, Rust, PhpStorm and the font GeistMono Nerd Font. This project carries no dependency to install and no test to run. Upgrade the machine with `./upgrade.sh`, which pulls this repository, runs `./install.sh` again, then upgrades PhpStorm, Hod, the Laravel installer, Rust and the system.

- `home/` — each configuration file, in the layout of `$HOME`
- `.hod/` — the intention, the rules and the skills of this project
