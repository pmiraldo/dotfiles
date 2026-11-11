#!/usr/bin/env bash
# Install dependencies and symlink the dotfiles into $HOME using GNU Stow.
#
# Usage: ./install.sh <desktop|laptop> [--no-apt] [--no-extras] [--chsh]
#   --no-apt     skip installing apt packages
#   --no-extras  skip fisher / tpm / Vundle bootstrap (needs network)
#   --chsh       make fish the login shell
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_PACKAGES=(i3 polybar fish tmux vim x11)
BACKUP="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

HOST="${1:-}"; shift || true
[[ -d "$REPO/hosts/$HOST" ]] || { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; echo "Available hosts: $(ls "$REPO/hosts" | xargs)"; exit 1; }

DO_APT=1; DO_EXTRAS=1; DO_CHSH=0
for a in "$@"; do
  case "$a" in
    --no-apt) DO_APT=0 ;; --no-extras) DO_EXTRAS=0 ;; --chsh) DO_CHSH=1 ;;
    *) echo "Unknown option: $a"; exit 1 ;;
  esac
done

log() { printf '\n==> %s\n' "$*"; }

# --- Ubuntu version check -----------------------------------------------------
. /etc/os-release
case "${VERSION_ID:-}" in
  24.04|26.04) ;;
  *) echo "Warning: tested on Ubuntu 24.04 and 26.04, found ${PRETTY_NAME:-unknown}." ;;
esac

# --- apt ----------------------------------------------------------------------
read_list() { grep -vE '^\s*(#|$)' "$1" 2>/dev/null || true; }

if (( DO_APT )); then
  log "Installing apt packages"
  sudo apt-get update
  wanted=$( { read_list "$REPO/packages/apt.txt"; read_list "$REPO/packages/apt-$HOST.txt"; } | sort -u)
  available=(); skipped=()
  for p in $wanted; do
    if apt-cache show "$p" >/dev/null 2>&1; then available+=("$p"); else skipped+=("$p"); fi
  done
  (( ${#skipped[@]} )) && echo "Warning: not available on this Ubuntu, skipped: ${skipped[*]}"
  sudo apt-get install -y "${available[@]}"
fi
command -v stow >/dev/null || { echo "stow is required: sudo apt install stow"; exit 1; }

# --- back up anything that would conflict with a symlink -----------------------
backup_conflicts() {  # $1 = stow dir, $2 = package
  local dir="$1" pkg="$2" f rel target
  while IFS= read -r -d '' f; do
    rel="${f#"$dir/$pkg/"}"; target="$HOME/$rel"
    if [[ -e "$target" || -L "$target" ]]; then
      [[ "$(readlink -f "$target")" == "$(readlink -f "$f")" ]] && continue
      mkdir -p "$BACKUP/$(dirname "$rel")"; mv "$target" "$BACKUP/$rel"
      echo "backed up ~/$rel -> $BACKUP/$rel"
    fi
  done < <(find "$dir/$pkg" -type f -print0)
}

# --- stow ---------------------------------------------------------------------
# --no-folding: link individual files, so files generated at runtime (fish_variables,
# logs, ...) never end up inside the repo.
log "Linking shared packages: ${SHARED_PACKAGES[*]}"
for p in "${SHARED_PACKAGES[@]}"; do
  backup_conflicts "$REPO" "$p"
  stow --no-folding -d "$REPO" -t "$HOME" -R "$p"
done
log "Linking host package: $HOST"
backup_conflicts "$REPO/hosts" "$HOST"
stow --no-folding -d "$REPO/hosts" -t "$HOME" -R "$HOST"

# --- extras (network) -----------------------------------------------------------
if (( DO_EXTRAS )); then
  if command -v fish >/dev/null; then
    log "Installing fish plugins with fisher"
    fish -c 'type -q fisher; or begin; curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher; end; fisher update' || echo "Warning: fisher setup failed"
  fi
  [[ -d "$HOME/.tmux/plugins/tpm" ]] || { log "Installing tmux plugin manager (tpm)"; git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; }
  [[ -d "$HOME/.vim/bundle/Vundle.vim" ]] || { log "Installing Vundle"; git clone --depth 1 https://github.com/VundleVim/Vundle.vim "$HOME/.vim/bundle/Vundle.vim"; }
fi

(( DO_CHSH )) && { log "Setting fish as login shell"; chsh -s "$(command -v fish)"; }

log "Done. Log out and back in (or restart i3 with Mod+Shift+r). See README.md for manual steps."
