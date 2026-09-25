geom=$(slurp) || exit 0

dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y%m%dT%H%M%S).png"

grim -g "$geom" "$file" || {
  notify-send -u critical "screenshot" "grim failed"
  exit 1
}

wl-copy -t image/png <"$file"

notify-send -t 2000 "screenshot" "Saved ${file##*/}"
