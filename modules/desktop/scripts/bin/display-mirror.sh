swaymsg -q "output * enable" || {
  notify-send -u critical "display-mirror" "swaymsg failed"
  exit 1
}

outputs=$(swaymsg -t get_outputs -r |
  jq -r '.[] | select(.active) | select(.name != "eDP-1") | .name') || {
  notify-send -u critical "display-mirror" "swaymsg failed"
  exit 1
}

pkill -x wl-mirror >/dev/null 2>&1 || true

if [ -z "$outputs" ]; then
  notify-send -t 2000 "display-mirror" "No external display connected"
  exit 0
fi

while read -r out; do
  [ -n "$out" ] || continue
  setsid wl-mirror --fullscreen-output "$out" eDP-1 >/dev/null 2>&1 &
done <<<"$outputs"
