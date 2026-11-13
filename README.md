# dotfiles

Personal configuration for my Ubuntu desktop and laptop: **i3**, **polybar**, **fish**, **tmux**, **vim** and **xterm**.
Files are kept in this repo and symlinked into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/).

Tested on Ubuntu **24.04** (the primary machine). Intended to also work on **26.04**: the installer skips apt packages that
are not available and prints a warning, but 26.04 has not been tested yet.

## Quick start

```bash
sudo apt install git stow
git clone <repo-url> ~/personal/dotfiles
cd ~/personal/dotfiles
./install.py desktop      # or: ./install.py laptop
```

`install.py <host> [options]`:

| Option        | Effect                                                   |
|---------------|----------------------------------------------------------|
| `--no-apt`    | do not install apt packages                              |
| `--no-extras` | skip fisher / tpm / Vundle bootstrap (needs network)     |
| `--chsh`      | make fish the login shell                                |
| `--dpi N`     | set the host's screen dpi (see [Screen scaling](#screen-scaling-dpi)) |

What it does:

1. Installs the apt packages in `packages/apt.txt` plus `packages/apt-<host>.txt`
   (packages unavailable on your Ubuntu version are skipped with a warning).
2. Moves any existing conflicting file to `~/.dotfiles_backup/<timestamp>/`.
3. Runs `stow --no-folding` for the shared packages, then for the host package. It is safe to run again.
   The `fonts` package installs the MesloLGS NF fonts into `~/.fonts/` (used by polybar, xterm and the fish prompt),
   and the font cache is refreshed afterwards.
4. Bootstraps fisher (fish plugins), tpm (tmux plugins) and Vundle (vim plugins).

Afterwards log out and back in, or press `Mod+Shift+r` inside i3.

## Layout

```
dotfiles/
├── install.py
├── packages/            apt.txt, apt-desktop.txt, apt-laptop.txt
├── i3/                  ~/.config/i3  (config + config.d/*.conf, scripts, wallpapers)
├── polybar/             ~/.config/polybar
├── fonts/               ~/.fonts (MesloLGS NF)
├── fish/                ~/.config/fish/{config.fish,fish_plugins}
├── tmux/                ~/.tmux.conf, ~/.tmux.conf.local
├── vim/                 ~/.vimrc
├── x11/                 ~/.Xresources (xterm), ~/.xinitrc, ~/.xsession
└── hosts/
    ├── desktop/         monitor layout, workspace-to-monitor pinning, NVIDIA bar module, 125 dpi (polybar 150)
    └── laptop/          battery bar module, 150 dpi, placeholders (brightness keys, laptop monitor)
```

Each top-level folder is a Stow package that mirrors `$HOME`, so `i3/.config/i3/config` becomes `~/.config/i3/config`.
Links are created per file (`--no-folding`), so files generated at runtime never end up in the repo.

### Per-machine settings

- **i3:** `~/.config/i3/config` ends with `include "local.conf"`. That file comes from `hosts/<host>/`.
- **X resources:** `~/.Xresources` includes `~/.Xresources.local`, also from `hosts/<host>/`.
- **polybar:** `config.ini` is shared and includes `~/.config/polybar/host.ini`, which comes from `hosts/<host>/`. That file
  defines `[host] dpi` and `modules-right` (the laptop adds the `battery` module after the volume, and may need its
  `battery`/`adapter` names checked with `ls /sys/class/power_supply`). `scripts/nvidia.sh` reads two NVIDIA GPUs on the
  desktop and is an empty stub on the laptop. The wired/wireless settings in `config.ini` are desktop values.

To add a new host, create `hosts/<name>/` with `.config/i3/local.conf`, `.Xresources.local` and `.config/polybar/host.ini`
(copy the laptop ones), then run `./install.py <name>`.

### Screen scaling (dpi)

Text size comes from two values per host, which `./install.py <host> --dpi N` writes into `hosts/<host>/`:

- `Xft.dpi` in `.Xresources.local`: used by xterm, the i3 font (pango), gvim, GTK apps and browsers.
- `dpi` in `.config/polybar/host.ini`: polybar ignores `Xft.dpi` when it has its own value.

Use the same number for both (4K laptop at 1.5x: 144 or 150). `Mod+Shift+r` reloads `~/.Xresources` into the X server, but
xterm reads it only at startup, so open a new xterm afterwards. Sizes in pixels (i3 gaps, the polybar font offset) do not
scale and may need tuning. This does not change the xdm login screen, which has its own dpi in `/etc/X11/xdm/`.

Polybar shortcuts in i3: `Mod+Shift+b` light theme, `Mod+Shift+n` dark theme, `Mod+Shift+m` compact polybar
(dpi, font and padding at 75%), `Mod+Shift+p` back to normal scale.

## Manual steps

These are not automated, because they are not packaged in apt or need interaction.

**fish.**
- `colorls` (used by the `ls` alias in `config.fish`): `gem install --user-install colorls`, and add the gem bin directory to `PATH`.
- Run `tide configure` once per machine to pick the prompt style. It is stored in `fish_variables`, which is not tracked.
- `bat` is installed as `batcat` on Ubuntu, and `config.fish` aliases `less` to it.

**tmux.** Inside tmux press `prefix + I` (capital i) to install the plugins listed in `~/.tmux.conf`.

**vim.** `vim +PluginInstall +qall` installs the Vundle plugins. YouCompleteMe also needs compiling:
`sudo apt install build-essential cmake python3-dev`, then `python3 ~/.vim/bundle/YouCompleteMe/install.py`.

**git.** No git config is tracked. On a new machine:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.editor vim
gh auth login && gh auth setup-git   # if you use the GitHub CLI
```

**Keyboard layout.** Set it from the X session with `setxkbmap`. To make it persistent, add a line to
`~/.config/i3/local.conf` (i.e. `hosts/<host>/.config/i3/local.conf`):

```
exec_always --no-startup-id setxkbmap -layout <layout> -variant <variant> -option <options>
```

Find the current values with `setxkbmap -query`, and list the options with `localectl list-x11-keymap-layouts`.
For the console and login screen, edit `/etc/default/keyboard`, then run `sudo dpkg-reconfigure keyboard-configuration`.

**NVIDIA (desktop).** Install the driver (`ubuntu-drivers install`) so that `nvidia-smi` works for the polybar module.

**picom (optional).** There is no compositor config in this repo. If you want one, `sudo apt install picom`, add
`picom/.config/picom/picom.conf`, and add `picom` to `SHARED_PACKAGES` in `install.py`.

## Day-to-day use

```bash
cd ~/personal/dotfiles
# Edit files in place (~/.config/... are symlinks into this repo), then:
git add -A && git commit

# Track a new file: move it into the right package, then re-stow
mv ~/.config/foo/foo.conf ~/personal/dotfiles/foo/.config/foo/foo.conf   # create dirs first
./install.py desktop --no-apt --no-extras

# Unlink one package
stow --no-folding -D -d ~/personal/dotfiles -t "$HOME" i3
```

## Not tracked on purpose

SSH/GPG keys, `.netrc`, tokens, `~/.gitconfig`, `fish_variables`, browser profiles, and the configs of `gh`, `khal`,
`vdirsyncer` and `davmail`, which contain account details. Keep machine-private fish settings in `~/.config/fish/local.fish`
(not tracked).
