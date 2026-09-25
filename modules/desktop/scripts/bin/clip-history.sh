# -no-custom: without it, typing text that matches nothing still returns that
# text as the "pick", and cliphist decode then fails on a line with no id.
pick=$(cliphist list | rofi -dmenu -no-custom -p Clip) || exit 0
[ -n "$pick" ] || exit 0

# Decode through a file, not $(...): command substitution strips NUL bytes and
# would corrupt every stored image/png. A pick can still fail to decode when
# -max-items evicted its id between the list and the choice, and piping straight
# into wl-copy would hand the selection away before the failure surfaced.
tmp=$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/clip-history.XXXXXX")
trap 'rm -f "$tmp"' EXIT

if ! printf '%s\n' "$pick" | cliphist decode >"$tmp" || [ ! -s "$tmp" ]; then
  notify-send -u critical "Clipboard" "Entry is gone from the history"
  exit 1
fi

wl-copy <"$tmp"
