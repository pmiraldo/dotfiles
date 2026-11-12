#!/usr/bin/env python3
"""Install dependencies and symlink the dotfiles into $HOME using GNU Stow.

Usage: ./install.py <host> [--no-apt] [--no-extras] [--chsh]
  --no-apt     skip installing apt packages
  --no-extras  skip fisher / tpm / Vundle bootstrap (needs network)
  --chsh       make fish the login shell
"""
import argparse
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parent
HOME = Path.home()
SHARED = ["i3", "polybar", "fish", "tmux", "vim", "x11", "fonts"]
BACKUP = HOME / ".dotfiles_backup" / datetime.now().strftime("%Y%m%d-%H%M%S")


def log(msg):
    print(f"\n==> {msg}")


def run(*cmd, check=True):
    return subprocess.run(cmd, check=check)


def ok(*cmd):
    return subprocess.run(cmd, capture_output=True).returncode == 0


def read_list(path):
    if not path.exists():
        return set()
    lines = (l.strip() for l in path.read_text().splitlines())
    return {l for l in lines if l and not l.startswith("#")}


def install_apt(host):
    log("Installing apt packages")
    run("sudo", "apt-get", "update")
    wanted = read_list(REPO / "packages/apt.txt") | read_list(REPO / f"packages/apt-{host}.txt")
    available = sorted(p for p in wanted if ok("apt-cache", "show", p))
    skipped = sorted(wanted - set(available))
    if skipped:
        print(f"Warning: not available on this Ubuntu, skipped: {' '.join(skipped)}")
    run("sudo", "apt-get", "install", "-y", *available)


def backup_conflicts(stow_dir, pkg):
    """Move files that would conflict with a symlink into BACKUP."""
    for f in (stow_dir / pkg).rglob("*"):
        if not f.is_file():
            continue
        rel = f.relative_to(stow_dir / pkg)
        target = HOME / rel
        if not (target.exists() or target.is_symlink()):
            continue
        if target.resolve() == f.resolve():
            continue
        dest = BACKUP / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(target, dest)
        print(f"backed up ~/{rel} -> {dest}")


def stow(stow_dir, pkg):
    backup_conflicts(stow_dir, pkg)
    # --no-folding: link individual files, so runtime-generated files never land in the repo.
    run("stow", "--no-folding", "-d", str(stow_dir), "-t", str(HOME), "-R", pkg)


def install_extras():
    if shutil.which("fish"):
        log("Installing fish plugins with fisher")
        fisher = ("type -q fisher; or begin; curl -sL https://raw.githubusercontent.com/jorgebucaran/"
                  "fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher; end; "
                  "fisher update")
        if run("fish", "-c", fisher, check=False).returncode:
            print("Warning: fisher setup failed")
    for name, url, dest in [
        ("tmux plugin manager (tpm)", "https://github.com/tmux-plugins/tpm", HOME / ".tmux/plugins/tpm"),
        ("Vundle", "https://github.com/VundleVim/Vundle.vim", HOME / ".vim/bundle/Vundle.vim"),
    ]:
        if not dest.exists():
            log(f"Installing {name}")
            run("git", "clone", "--depth", "1", url, str(dest))


def main():
    hosts = sorted(p.name for p in (REPO / "hosts").iterdir() if p.is_dir())
    ap = argparse.ArgumentParser(description="Symlink dotfiles into $HOME with GNU Stow.")
    ap.add_argument("host", choices=hosts)
    ap.add_argument("--no-apt", action="store_true", help="skip installing apt packages")
    ap.add_argument("--no-extras", action="store_true", help="skip fisher / tpm / Vundle bootstrap")
    ap.add_argument("--chsh", action="store_true", help="make fish the login shell")
    args = ap.parse_args()

    if not args.no_apt:
        install_apt(args.host)
    if not shutil.which("stow"):
        sys.exit("stow is required: sudo apt install stow")

    log(f"Linking shared packages: {' '.join(SHARED)}")
    for pkg in SHARED:
        stow(REPO, pkg)
    log(f"Linking host package: {args.host}")
    stow(REPO / "hosts", args.host)

    if shutil.which("fc-cache"):
        log("Refreshing font cache")
        run("fc-cache", "-f", str(HOME / ".fonts"))

    if not args.no_extras:
        install_extras()
    if args.chsh:
        log("Setting fish as login shell")
        run("chsh", "-s", shutil.which("fish"))

    log("Done. Log out and back in (or restart i3 with Mod+Shift+r). See README.md for manual steps.")


if __name__ == "__main__":
    main()
