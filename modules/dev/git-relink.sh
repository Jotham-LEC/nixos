usage() {
  cat <<'EOF'
Repoints github.com remotes at wherever their repo actually lives now.

  git relink                        # every remote of the repo you are in
  git relink ~/Projects/some-repo   # named repos
  git relink --scan ~/Projects      # every repo one level under a directory
  git relink -n --scan ~/Projects   # show the rewrites, change nothing
EOF
}

dry_run=false
verify=true
scanned=false
scan_dirs=()
targets=()

die() {
  printf 'git-relink: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    -n | --dry-run) dry_run=true ;;
    --no-verify) verify=false ;;
    --scan)
      [[ ${2:-} ]] || die "--scan needs a directory"
      scan_dirs+=("$2")
      scanned=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*) die "unknown option: $1" ;;
    *) targets+=("$1") ;;
  esac
  shift
done

gh auth status >/dev/null 2>&1 || die "gh is not authenticated (run: gh auth login)"

for dir in "${scan_dirs[@]}"; do
  [[ -d $dir ]] || die "not a directory: $dir"
  for candidate in "$dir"/*/; do
    [[ -e ${candidate}.git ]] && targets+=("${candidate%/}")
  done
done

if ((${#targets[@]} == 0)); then
  # A --scan that matched nothing must not quietly fall through to the cwd:
  # `git relink --scan ~/Prjects` would then rewrite this repo's remotes
  # instead of reporting the typo.
  $scanned && die "--scan found no git repos under: ${scan_dirs[*]}"
  targets+=("$(git rev-parse --show-toplevel 2>/dev/null)") ||
    die "not inside a git repo -- pass a path or --scan"
fi

changed=0
failed=0

for repo in "${targets[@]}"; do
  if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
    printf '%s: not a git repo, skipped\n' "$repo" >&2
    failed=$((failed + 1))
    continue
  fi

  label="$(basename "$repo")"

  while read -r remote; do
    url="$(git -C "$repo" remote get-url "$remote")"
    [[ $url == *github.com[:/]* ]] || continue

    rest="${url#*github.com}"
    prefix="${url%"$rest"}"
    sep="${rest:0:1}"
    path="${rest:1}"
    suffix=""
    path="${path%/}"
    if [[ $path == *.git ]]; then
      suffix=".git"
      path="${path%.git}"
    fi
    [[ $path == */* && $path != */*/* ]] || continue

    if ! canonical="$(gh api "repos/$path" --jq .full_name 2>/dev/null)"; then
      printf '%-32s %s -> unreachable (deleted, private, or wrong gh account)\n' \
        "$label" "$path" >&2
      failed=$((failed + 1))
      continue
    fi

    [[ $canonical == "$path" ]] && continue

    new_url="${prefix}${sep}${canonical}${suffix}"

    if $dry_run; then
      printf '%-32s %s  %s -> %s\n' "$label" "$remote" "$path" "$canonical"
      changed=$((changed + 1))
      continue
    fi

    git -C "$repo" remote set-url "$remote" "$new_url"

    # --exit-code exits 2 when the transport worked but matched no ref, which is
    # what a brand-new empty repo looks like. Only a real transport failure
    # (auth, DNS, gone) is grounds for reverting the rewrite.
    ls_status=0
    if $verify; then
      git -C "$repo" ls-remote --exit-code "$remote" HEAD >/dev/null 2>&1 || ls_status=$?
    fi
    if ((ls_status != 0 && ls_status != 2)); then
      git -C "$repo" remote set-url "$remote" "$url"
      printf '%-32s %s  %s -> %s FAILED to fetch, reverted\n' \
        "$label" "$remote" "$path" "$canonical" >&2
      failed=$((failed + 1))
      continue
    fi

    printf '%-32s %s  %s -> %s\n' "$label" "$remote" "$path" "$canonical"
    changed=$((changed + 1))
  done < <(git -C "$repo" remote)
done

if ((changed == 0 && failed == 0)); then
  echo "every github remote already points at its canonical location"
fi
((failed == 0))
