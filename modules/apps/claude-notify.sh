case "${1:-}" in
  stop)
    cwd="$(jq -r '.cwd // "?"')"
    notify-send -a claude-code -t 8000 "Claude Code done" "${cwd##*/}"
    ;;
  notification)
    message="$(jq -r '.message // "Waiting for you"')"
    notify-send -a claude-code -u critical "Claude Code" "$message"
    ;;
  *)
    echo "usage: claude-notify stop|notification < hook-input.json" >&2
    exit 1
    ;;
esac
