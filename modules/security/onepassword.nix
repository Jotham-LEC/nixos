{
  flake.modules.nixos.default =
    { username, ... }:
    {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ username ];
      };

      # polkit has no per-action expiry: this sets the window for every
      # AUTH_*_KEEP rule on the system, not just the 1Password one below.
      security.polkit.settings.Polkitd.ExpirationSeconds = 600;
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id.indexOf("com.1password.1Password.") === 0 &&
              subject.local && subject.active && subject.user === "${username}") {
            return polkit.Result.AUTH_SELF_KEEP;
          }
        });
      '';
    };

  flake.modules.homeManager.default =
    { lib, identity, ... }:
    {
      xdg.configFile."1Password/ssh/agent.toml".text = lib.concatMapStringsSep "\n" (vault: ''
        [[ssh-keys]]
        vault = "${vault}"
      '') identity.vaults;
    };
}
