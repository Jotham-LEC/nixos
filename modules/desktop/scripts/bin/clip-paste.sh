case "${1:-}" in
  --list-types)
    exec wl-paste --list-types
    ;;
  -t)
    [ "$#" -eq 2 ] || {
      echo "usage: clip-paste -t TYPE" >&2
      exit 1
    }
    exec wl-paste -n -t "$2"
    ;;
esac

exec wl-paste -n
