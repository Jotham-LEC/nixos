[ "$#" -eq 1 ] || {
  echo "usage: type-text <string>" >&2
  exit 1
}

# shellcheck disable=SC2016
setsid sh -c '
	exec 9>"${XDG_RUNTIME_DIR:-/tmp}/type-text.lock"
	flock 9
	sleep 0.2
	wtype -- "$1" ||
		notify-send -u critical "type-text" "wtype failed"
' _ "$1" >/dev/null 2>&1 &
