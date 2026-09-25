{
  flake.modules.nixos.default =
    {
      lib,
      username,
      identity,
      ...
    }:
    {
      sops.secrets = lib.mapAttrs' (
        name: _: lib.nameValuePair "mail/${name}" { owner = username; }
      ) identity.mail;
    };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      lib,
      osConfig,
      identity,
      ...
    }:
    let
      passwordCommand =
        account:
        pkgs.writeShellScript "mail-password-${account}" ''
          set -eu
          password="$(${lib.getExe' pkgs.coreutils "tr"} -d '\n' < ${
            osConfig.sops.secrets."mail/${account}".path
          })"
          [ -n "$password" ]
          printf '%s' "$password"
        '';

      onNotifyPost =
        account:
        pkgs.writeShellScript "mail-notify-${account}" ''
          ${lib.getExe' pkgs.libnotify "notify-send"} -a mail -i mail-unread 'New mail' '${account}' || true
          ${lib.getExe' pkgs.systemd "systemctl"} --user is-active --quiet emacs.service || exit 0
          ${lib.getExe' config.services.emacs.package "emacsclient"} --no-wait --eval \
            '(when (fboundp (quote mu4e-update-index)) (ignore-errors (mu4e-update-index)))' \
            >/dev/null 2>&1 || true
        '';

      mailSync = pkgs.writeShellApplication {
        name = "mail-sync";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs) gawk isync;
        };
        text = builtins.readFile ./mail-sync.sh;
      };

      gmailAccount = name: account: {
        inherit (account) address;
        aliases = account.aliases or [ ];
        primary = account.primary or false;
        flavor = "gmail.com";
        realName = identity.realName;
        signature.text = account.signature;
        passwordCommand = "${passwordCommand name}";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          patterns = [
            "INBOX"
            "[Gmail]/All Mail"
            "[Gmail]/Sent Mail"
            "[Gmail]/Drafts"
            "[Gmail]/Trash"
          ];
          # Bounds the local copy of each mailbox (All Mail especially) to the
          # newest 3000; older read, unflagged mail goes locally, not on Gmail.
          extraConfig.channel.MaxMessages = 3000;
        };
        imapnotify = {
          enable = true;
          boxes = [ "INBOX" ];
          onNotify = "${lib.getExe' pkgs.isync "mbsync"} ${name}";
          onNotifyPost = "${onNotifyPost name}";
        };
        msmtp.enable = true;
        mu.enable = true;
      };
    in
    {
      programs.mbsync.enable = true;
      programs.msmtp.enable = true;
      programs.mu.enable = true;
      services.imapnotify.enable = true;

      programs.msmtp.configContent = lib.mkBefore ''
        defaults
        logfile ~/.local/state/msmtp.log
      '';

      home.packages = [ mailSync ];

      programs.doom-emacs.extraPackages = epkgs: [ epkgs.mu4e ];

      programs.doom-emacs.extraBinPackages = [
        mailSync
        pkgs.isync
        pkgs.msmtp
        pkgs.mu
      ];

      accounts.email.maildirBasePath = "${config.home.homeDirectory}/Mail";

      accounts.email.accounts = lib.mapAttrs gmailAccount identity.mail;
    };
}
