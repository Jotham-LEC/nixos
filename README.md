# nixos

Jotham's NixOS configuration. One machine: `x1c`, a ThinkPad.

```bash
nh os switch                         # apply
nixos-rebuild test --flake .#x1c     # apply without touching the bootloader
nix flake check                      # formatting (treefmt) + does the system build
nix develop                          # treefmt, sops, ssh-to-age, age, nix-update, shellcheck, shfmt
nix fmt                              # deadnix + nixfmt on *.nix, shfmt + shellcheck on scripts
```

## The one rule

Every `.nix` file under `modules/` is picked up automatically — `import-tree`
globs the directory, so there is no `imports` list to maintain anywhere. Each
file is a flake-parts module that contributes a fragment to two shared piles:

```nix
{
  flake.modules.nixos.default = { ... };        # the machine
  flake.modules.homeManager.default = { ... };  # the user account
}
```

**One topic = one file = both halves.** `modules/hardware/audio.nix` holds
PipeWire and the user's mixer four lines apart. `modules/host.nix` is the only
file that builds a machine.

## Layout

| Path | What |
|---|---|
| `flake.nix` | 9 inputs, one line of output |
| `modules/flake/` | the flake itself: systems, nixpkgs, packages, checks, devshell, formatting |
| `modules/host.nix` | assembles `nixosConfigurations.x1c` |
| `modules/{system,hardware,desktop,apps,dev,services,security}/` | the config, by topic |
| `hosts/x1c/` | hardware facts and the disko disk layout |
| `pkgs/` | four packages nixpkgs does not have |
| `secrets/secrets.yaml` | sops-encrypted, committed |
| `doom/` | Emacs config, built by `nix-doom-emacs-unstraightened` |
| `scripts/update-pkgs.sh` | bumps `pkgs/*.nix` (independent of `nix flake update`) |

## Docs

- **[INSTALL.md](INSTALL.md)** — installing on bare metal, the manual post-install
  steps, and how secrets work day to day.

## Conventions

- Comment the *why*, never the *what*: a workaround, a non-obvious constraint,
  or a condition for removal ("drop once upstream PR #N lands") sits next to
  the line it explains, because that is where the next reader will be.
  History-only rationale (why it changed) still belongs in the commit message.
  Commented-out code is reserved for deliberately disabled functionality.
- Day-to-day commits are date-stamped snapshots (`2026-09-16`) with no body.
  A change whose reason isn't obvious from the diff gets its own commit, with a
  topic subject and a body saying why. A sweeping mechanical change (a tree-wide rename, a comment strip)
  also gets its own commit rather than riding along with something that needs
  explaining.
- No extra substituters, so a stock `nix.conf` can install this. Both candidates
  were measured against the 1,431-path `emacs-pgtk-with-doom` closure and
  rejected. `doom-emacs-unstraightened.cachix.org` was configured for a while and
  served *nothing* `cache.nixos.org` did not already have; the seven paths that
  matter — `doomdir` through the final `emacs-pgtk-with-doom` — are 404 on both.
  That is structural: `doomdir` is built from this repo's `doom/`, so every path
  below it is unique to this config and no upstream cache can ever hold them. The
  lever that does work is bumping `nix-doom-emacs-unstraightened` / `doomemacs` /
  `emacs-overlay` deliberately rather than on every `nix flake update` — they
  rebuild most of that closure.
- Read secrets by path, never by value:
  `osConfig.sops.secrets."<name>".path`.
- Shell scripts live as real `*.sh` files without a shebang, wrapped with
  `writeShellApplication` so their dependencies are pinned and `shellcheck`
  runs at build time. The `.sh` suffix is what `nix fmt` and `.editorconfig`
  match on. `scripts/update-pkgs.sh` is the exception: it runs straight from the
  checkout, so it keeps its shebang.
