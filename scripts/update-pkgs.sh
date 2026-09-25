#!/usr/bin/env bash
#   scripts/update-pkgs.sh           # bump every pkgs/*.nix to the latest GitHub release
#   scripts/update-pkgs.sh --build   # extra args pass through to nix-update
#   UPDATE_PKGS_NO_VERIFY=1 …        # skip the post-bump rebuild
# Requires nix-update on PATH: nix develop

set -euo pipefail

die() {
  printf 'update-pkgs: %s\n' "$*" >&2
  exit 1
}

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

system="$(nix eval --impure --raw --expr builtins.currentSystem)"
# Not `mapfile < <(nix eval ...)`: a process substitution's exit status is
# unobservable and mapfile returns 0 on empty input, so a broken flake would
# silently bump nothing and then "verify 0 package(s)" successfully.
names="$(nix eval --raw ".#packages.${system}" \
  --apply 'ps: builtins.concatStringsSep "\n" (builtins.attrNames ps)')"
[[ -n $names ]] || die "no packages under .#packages.${system}"
mapfile -t pkgs <<<"$names"

failed=()
for p in "${pkgs[@]}"; do
  printf '==> %s %s\n' "$p" "$(nix eval --raw ".#${p}.version")"
  nix-update --flake "$p" --version=stable --use-github-releases "$@" ||
    failed+=("$p")
done

if ((${#failed[@]})); then
  printf 'update-pkgs: failed to bump: %s\n' "${failed[*]}" >&2
  exit 1
fi

if [[ -n ${UPDATE_PKGS_NO_VERIFY-} ]]; then
  printf '==> skipping verification (UPDATE_PKGS_NO_VERIFY set)\n'
  exit 0
fi

printf '==> verifying %s package(s) build\n' "${#pkgs[@]}"
if ! nix build --no-link --keep-going "${pkgs[@]/#/.#}"; then
  printf 'update-pkgs: bumped, but the above package(s) do not build.\n' >&2
  printf '             Inspect the diff under pkgs/ -- a stale hash and a tag\n' >&2
  printf '             with no release assets both look like a clean bump.\n' >&2
  exit 1
fi
