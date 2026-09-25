isyncrc="${XDG_CONFIG_HOME:-$HOME/.config}/isyncrc"

if [ ! -r "$isyncrc" ]; then
  echo "mail-sync: no $isyncrc" >&2
  exit 1
fi

accounts=()
while IFS= read -r account; do
  accounts+=("$account")
done < <(awk '/^IMAPAccount /{print $2}' "$isyncrc")

if [ "${#accounts[@]}" -eq 0 ]; then
  echo "mail-sync: no IMAPAccount stanzas in $isyncrc" >&2
  exit 1
fi

pids=()
for account in "${accounts[@]}"; do
  mbsync "$account" &
  pids+=("$!")
done

status=0
for pid in "${pids[@]}"; do
  wait "$pid" || status=1
done

exit "$status"
