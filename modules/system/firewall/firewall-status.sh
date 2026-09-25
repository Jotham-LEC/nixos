if [ "$(id -u)" -ne 0 ]; then
  exec sudo -- "$0" "$@"
fi

chain=nixos-fw

rules() {
  "$1" -S "$chain" 2>/dev/null || true
}

policy() {
  iptables -S "$1" 2>/dev/null | awk '$1 == "-P" { print $3; exit }'
}

ports() {
  awk -v want="$1" '
		$0 ~ /-j nixos-fw-accept/ {
			iface = ""; proto = ""; port = ""
			for (i = 1; i < NF; i++) {
				if ($i == "-i")                    iface = $(i + 1)
				else if ($i == "-p")               proto = $(i + 1)
				else if ($i == "--dport")          port  = $(i + 1)
				else if ($i == "--dports")         port  = $(i + 1)
			}
			if (port == "" || proto == "") next
			if (want == "global" && iface != "") next
			if (want != "global" && iface != want) next
			gsub(/:/, "-", port)
			printf "  %s/%s\n", port, proto
		}'
}

interfaces() {
  awk '$0 ~ /-j nixos-fw-accept/ { for (i = 1; i < NF; i++) if ($i == "-i") print $(i + 1) }' |
    sort -u
}

if ! systemctl is-active --quiet firewall.service; then
  printf 'Firewall: INACTIVE\n'
  exit 1
fi

all="$({
  rules iptables
  rules ip6tables
})"

printf 'Firewall: active (%s backend)\n\n' "$(iptables --version | awk '{print $NF}' | tr -d '()')"

printf 'Default policy\n'
printf '  incoming   %s\n' "$(policy INPUT)"
printf '  outgoing   %s\n' "$(policy OUTPUT)"
printf '  forward    %s\n\n' "$(policy FORWARD)"

printf 'Trusted interfaces (everything allowed)\n'
printf '%s\n' "$all" | awk '$0 ~ /-j nixos-fw-accept/ && $0 !~ /--dport/ {
	for (i = 1; i < NF; i++) if ($i == "-i") print "  " $(i + 1) }' | sort -u
printf '\n'

open_global="$(printf '%s\n' "$all" | ports global | sort -u)"
printf 'Open on EVERY interface\n'
if [ -n "$open_global" ]; then printf '%s\n' "$open_global"; else printf '  (none)\n'; fi
printf '\n'

for iface in $(printf '%s\n' "$all" | interfaces); do
  scoped="$(printf '%s\n' "$all" | ports "$iface" | sort -u)"
  [ -n "$scoped" ] || continue
  printf 'Open on %s only\n' "$iface"
  printf '%s\n\n' "$scoped"
done

# Docker's nat rules match before nixos-fw, so published ports are open whatever
# the chains above say. `docker ps` is the only record that needs no privilege
# and still works under `userland-proxy: false`.
if command -v docker >/dev/null 2>&1 && running="$(docker ps --format '{{.Names}}	{{.Ports}}' 2>/dev/null)"; then
  published="$(printf '%s\n' "$running" | awk -F'\t' '
		$2 == "" { next }
		{
			n = split($2, specs, /, /)
			for (i = 1; i <= n; i++) {
				arrow = index(specs[i], "->")
				if (arrow == 0) continue          # exposed only, not bound to the host
				bind = substr(specs[i], 1, arrow - 1)
				dest = substr(specs[i], arrow + 2)
				colon = 0
				for (j = length(bind); j > 0; j--)
					if (substr(bind, j, 1) == ":") { colon = j; break }
				addr = colon ? substr(bind, 1, colon - 1) : ""
				note = (addr == "127.0.0.1" || addr == "[::1]") ? "" : "   <-- reachable from the network"
				printf "  %-22s %s -> %s%s\n", $1, bind, dest, note
			}
		}')"
  printf 'Docker-published ports (these bypass the NixOS firewall)\n'
  if [ -n "$published" ]; then printf '%s\n' "$published"; else printf '  (none)\n'; fi
  printf '\n'
fi

if printf '%s\n' "$all" | grep -q 'nixos-fw-log-refuse'; then
  printf 'Logging: on — journalctl -k --grep "refused connection"\n'
else
  printf 'Logging: off\n'
fi
