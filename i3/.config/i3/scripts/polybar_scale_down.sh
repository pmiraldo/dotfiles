#!/usr/bin/env bash
set -euo pipefail

BASE_CFG="${HOME}/.config/polybar/config.ini"
SCALED_CFG="/tmp/polybar-config-50.ini"

if [ ! -f "${BASE_CFG}" ]; then
  echo "Missing polybar config: ${BASE_CFG}" >&2
  exit 1
fi

perl -0pe '
  sub fmt {
    my ($n) = @_;
    return "0" if abs($n) < 1e-9;
    my $s = sprintf("%.4f", $n);
    $s =~ s/0+$//;
    $s =~ s/\.$//;
    return $s;
  }

  my $in_top = 0;
  my @out;
  for my $line (split(/\n/, $_, -1)) {
    if ($line =~ /^\s*\[bar\/top\]\s*$/) {
      $in_top = 1;
      push @out, $line;
      next;
    }
    if ($line =~ /^\s*\[/) {
      $in_top = 0;
      push @out, $line;
      next;
    }

    if ($in_top) {
      $line =~ s/^(\s*(?:dpi|dpi-x|dpi-y)\s*=\s*)(-?\d+(?:\.\d+)?)(\s*)$/$1 . fmt($2 * 0.75) . $3/e;
      $line =~ s/^(\s*(?:height|line-size|radius|border-size)\s*=\s*)(-?\d+(?:\.\d+)?)([a-z%]*)(\s*)$/$1 . fmt($2 * 1) . $3 . $4/e;
      $line =~ s/^(\s*(?:padding-left|padding-right|module-margin)\s*=\s*)(-?\d+(?:\.\d+)?)(\s*)$/$1 . fmt($2 * 0.75) . $3/e;
      $line =~ s/^(\s*font-\d+\s*=\s*[^;\n]*;)(-?\d+(?:\.\d+)?)(\s*)$/$1 . fmt($2 * 0.75) . $3/e;
    }

    push @out, $line;
  }
  $_ = join("\n", @out);
' "${BASE_CFG}" > "${SCALED_CFG}"

polybar-msg cmd quit >/dev/null 2>&1 || true
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log >/dev/null
polybar --config="${SCALED_CFG}" top 2>&1 | tee -a /tmp/polybar1.log & disown
