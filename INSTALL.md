# Installing this config on a machine

## From 1Password
Everything the install cannot derive. The laptop is being wiped, so read these
from your phone or another machine.

| Item | Used for |
|---|---|
| Secure note "nixos-secrets" | Where this repo lives, and a read-only token to clone it on the ISO. Also holds the two files under Recovery. |
| x1c SSH host key (ssh_host_ed25519_key) | sops decrypts with it. Without it every secret is missing and msmtp comes up empty. |
| admin age key (keys.txt) | Editing secrets afterwards, as your user, without root. Not needed during the install. |
| jothamlec password | Logging in. mutableUsers = false, so there is no other copy. |
| root password | Rescue shell. Same. |

Clone the private repo, not the published one. The published copy carries a
placeholder modules/identity.nix and a placeholder secrets/secrets.yaml, so it
installs a machine with the wrong name, no mail and no servers. Recovery below
says what to do when the private repo is unreachable.

## What you need

* A NixOS installer ISO on a USB stick. Nothing else on it.
* Network on the target.
* The items above, to hand.

## Install
```bash
export NIX_CONFIG='experimental-features = nix-command flakes'

# 1. Expand the installer's primary RAM limits
sudo mount -o remount,size=24G,noatime /nix/.rw-store

# 2. Setup your Git credentials safely using root permissions
#    All four values come from the 1Password note "nixos-secrets".
FORGE=<forge-host>; FORGE_USER=<account>; REPO=<repo>; TOKEN=<token>

sudo install -d -m700 /root/gc
printf 'https://%s:%s@%s\n' "$FORGE_USER" "$TOKEN" "$FORGE" | sudo tee /root/gc/creds > /dev/null
sudo chmod 600 /root/gc/creds
sudo git config --global credential.helper 'store --file=/root/gc/creds'

FLAKE="git+https://$FORGE/$FORGE_USER/$REPO.git?ref=main"
nix flake metadata "$FLAKE"            # resolve BEFORE wiping anything

# 3. Seed your host key
sudo touch /root/ssh_host_ed25519_key
sudo chmod 600 /root/ssh_host_ed25519_key
sudo vi /root/ssh_host_ed25519_key     # paste from 1Password

# 4. Use Disko to handle partitioning, formatting, and disk mounting
sudo nix run github:nix-community/disko -- \
  --mode disko \
  --flake "$FLAKE#x1c"

# 5. Inject secrets into the physical target mount before final configuration installation
sudo mkdir -p /mnt/etc/ssh
sudo cp /root/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key
sudo chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key

# 6. Run native hardware installation to bypass RAM exhaustion
sudo nixos-install --no-root-password --flake "$FLAKE#x1c" --max-jobs 4 --cores 4
```

Reboot. Step 4 partitions and formats and leaves the target mounted at /mnt;
step 5 puts the host key inside that mount; step 6 copies the closure and
installs. They are three commands rather than one disko-install because
disko-install runs the build in the ISO's tmpfs and exhausts RAM on this closure.

* disko --mode disko reads hosts/x1c/disk.nix and takes the device from there,
so there is no --disk flag to get wrong. Change the device in disk.nix, never
on the command line. It is the drive's /dev/disk/by-id name, so a replacement
SSD needs its own: ls -l /dev/disk/by-id on the ISO.
* Step 5 is what seeds the host key before first activation, so sops can
decrypt. Nothing else does it -- skip it and every secret comes up missing.
* --max-jobs 4 --cores 4 keeps nixos-install inside the ISO's memory. Drop them
and the build can OOM part-way through.
* ?ref=main is required: with no ref Nix guesses master, which does not exist.
* The credential helper is what authenticates; Nix's netrc-file does not apply
to git+https.

## After first boot
Secrets first -- step 5 seeded the host key itself, but not its .pub, and the
admin key is not seeded at all:

```
# regenerate the host key's .pub (sshd and sops do not need it; rotation does)
sudo ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key \
  | sudo tee /etc/ssh/ssh_host_ed25519_key.pub >/dev/null
# admin age key -- nothing in the flake creates this
install -d -m700 ~/.config/sops/age
install -m600 /dev/null ~/.config/sops/age/keys.txt
vi ~/.config/sops/age/keys.txt        # paste from 1Password
```
Sign in to 1Password next -- its SSH agent is what authenticates the clone, and
the repo is private. Then clone to exactly this path, because
programs.nh.flake hardcodes it and nothing creates it:

```
git clone "git@$FORGE:$FORGE_USER/$REPO.git" ~/Projects/nixos   # host alias and user per the note
cd ~/Projects/nixos
nix develop -c sops --decrypt secrets/secrets.yaml >/dev/null && echo "secrets OK"
```

Clone over SSH, not HTTPS: the access token is for the ISO only, and an HTTPS
remote would keep asking for it on every push. sops lives in the devshell
only, hence nix develop -c.
Then:
```
tailscale up                          # until this runs there is no inbound SSH
claude                                # login
powerprofilesctl set power-saver
```
Plus wifi.

Mail for mu4e is separate, and needs one pass by hand:
```
mkdir -p ~/Mail                       # before the first switch, not after
mail-sync                             # initial download; hours, and a few GB
mu index
```
mail-sync, not mbsync --all: one mbsync invocation walks its channels serially,
so --all syncs the four accounts one after another. mail-sync forks one mbsync
per account instead, which is what mu4e's U runs too. Per-mailbox state files
are lock-protected, so the concurrency is safe.
Each Gmail account gets its own app password under mail/ in sops
secrets/secrets.yaml, named for the account in modules/identity.nix; msmtp,
mbsync and goimapnotify all read the same one. They are app passwords, not OAuth, so each
account needs 2-step verification on and an app password minted at
Google Account > Security > App passwords. Stored as the bare 16 characters,
without the display spaces Google shows; the spaced form also authenticates, so
a stray space is not what is wrong. mu init runs during activation,
but it re-runs whenever the account set changes and will fail if a live mu4e
holds the Xapian lock: quit mu4e before switching when you add or drop an
account.

The second Emacs is manual too. `emacs`, `emacsclient` and `doom` are Doom;
`emacs-minimal` is stock emacs-pgtk pointed at a config this flake does not
manage:

```
git clone https://github.com/jamescherti/minimal-emacs.d ~/.minimal-emacs.d
```

Deliberately not nix-managed: the point is editing `post-init.el` and
`M-x eval-buffer` without a rebuild, and installing from MELPA into
`~/.minimal-emacs.d/elpa` rather than waiting nine minutes on `emacsPackages`
derivations that no cache holds. `init.el` and `early-init.el` are upstream's --
never edit them, `git pull` them; your changes go in `pre-init.el`,
`post-init.el`, `pre-early-init.el`, `post-early-init.el`.

Do not run `server-start` or `server-force-delete` there. The default socket is
`$XDG_RUNTIME_DIR/emacs/server`, which the Doom daemon already owns:
`server-start` only warns, but `server-force-delete` unlinks a live socket
(recover with `systemctl --user restart emacs.socket`). If you want a server in
the tinkering instance, `(setq server-name "minimal")` in `post-init.el` first,
and reach it with `emacsclient -s minimal`.
## If something goes wrong

* Rebuild broke the system. Reboot, pick the previous systemd-boot entry
(5 kept). Prefer test over switch while experimenting -- it leaves the
bootloader alone, so a reboot undoes it.
* Cannot log in. There is no passwd; mutableUsers = false. Boot the
previous generation, or the ISO plus nixos-enter. Both passwords are in
1Password.
* Change a password. Replace the hash under passwords/ in
sops secrets/secrets.yaml with a new mkpasswd -m yescrypt, rebuild, then
verify with su - jothamlec from a normal shell -- root can su to anyone
without a prompt, so testing as root proves nothing.

## Secrets
secrets/secrets.yaml is sops-encrypted and committed. Two age recipients in
.sops.yaml:

* host -- from /etc/ssh/ssh_host_ed25519_key. What sops-nix uses at
activation. Step 5 of the install copies it into /mnt, and sshd-keygen only
generates a key when the file is missing or empty, so it will not clobber
yours. Seed it or the machine mints a different key and decrypts nothing.
The matching .pub is neither seeded nor regenerated -- see above.
* admin -- ~/.config/sops/age/keys.txt. Nothing in the flake creates,
references or generates this file; it is entirely manual and only you have it.
Without it you can still rebuild, but you cannot edit secrets as your user.

Either key alone decrypts everything, and the disk is not encrypted. Both keys,
plus the user and root passwords, live in 1Password.
Decrypted values land in /run/secrets (tmpfs), mode 0400. The ciphertext enters
/nix/store; plaintext never does.
```
sops secrets/secrets.yaml              # edit
sops --decrypt secrets/secrets.yaml    # read
```
Adding one: put it in the yaml, declare it in the module that reads it
(owner = username if a user unit reads it), then read it by path --
osConfig.sops.secrets."<name>".path from home-manager,
config.sops.secrets."<name>".path from NixOS. Never inline a value in a .nix
file; it would land in the store as plaintext. For KEY=value form, extend
sops.templates.
Rotating the host key: replace it, recompute with
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub, update .sops.yaml, then
sops updatekeys secrets/secrets.yaml -- before rebooting.

## Recovery
Installing depends on three things, in this order: 1Password, then the private
forge, then this repo. 1Password holds the forge's address, the host key, the
admin age key and both passwords, so without it nothing below matters. The
forge is the single point of failure after that -- it holds the only copy of
the two files the published repo deliberately does not have:

* modules/identity.nix -- name, mail accounts, 1Password vaults, ssh aliases
and the disk's by-id name. Everything else in the tree reads it.
* secrets/secrets.yaml -- every value, and (because sops encrypts values but
not the mapping keys) the names too.

Nothing else is irreplaceable. The four server .pub files are regenerable: the
private halves live in 1Password, which shows the public key for any SSH item.

So the "nixos-secrets" note carries both files verbatim, as fields named
modules/identity.nix and secrets/secrets.yaml. secrets.yaml is ciphertext and
the admin age key that decrypts it is in the same vault, so the note is safe
but goes stale -- refresh it whenever you run `sops secrets/secrets.yaml`:

```
op item edit nixos-secrets --vault Personal \
  "modules/identity.nix[text]=$(cat modules/identity.nix)" \
  "secrets/secrets.yaml[text]=$(cat secrets/secrets.yaml)"
```

A second private git remote does the same job without going stale, and is the
better answer if you are willing to maintain one.

With that note and 1Password alone, a wiped machine is recoverable: install
from the published repo, then paste the two files back over their placeholders
before the first switch.
