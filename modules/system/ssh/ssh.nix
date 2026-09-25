{
  flake.modules.nixos.default =
    {
      config,
      lib,
      username,
      identity,
      ...
    }:
    {
      sops.secrets = lib.mapAttrs' (name: _: lib.nameValuePair "hosts/${name}" { }) identity.hosts;

      sops.templates."ssh-hosts" = {
        owner = username;
        content = lib.concatStrings (
          lib.mapAttrsToList (name: h: ''
            Host ${name}
              HostName ${config.sops.placeholder."hosts/${name}"}
              User ${h.user}
              IdentityFile ~/.ssh/${h.key}.pub
          '') identity.hosts
        );
      };

      programs.ssh.knownHosts.${identity.forgejo.host}.publicKey = identity.forgejo.hostKey;

      users.users.${username}.openssh.authorizedKeys.keyFiles = [ ./jothamlec.pub ];

      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      programs.mosh = {
        enable = true;
        openFirewall = false;
      };

      networking.firewall.interfaces.tailscale0 = {
        allowedTCPPorts = [ 22 ];
        allowedUDPPortRanges = [
          {
            from = 60000;
            to = 61000;
          }
        ];
      };
    };

  flake.modules.homeManager.default =
    {
      lib,
      osConfig,
      identity,
      ...
    }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [ osConfig.sops.templates."ssh-hosts".path ];
        settings = {
          ${identity.forgejo.host} = {
            User = identity.forgejo.user;
            IdentityFile = "~/.ssh/${identity.forgejo.key}.pub";
          };
          "*" = {
            IdentityAgent = "~/.1password/agent.sock";
            # Otherwise the agent offers every key to every host and trips MaxAuthTries.
            IdentitiesOnly = true;
            ServerAliveInterval = 30;
            ServerAliveCountMax = 3;
          };
        };
      };

      # Every committed key, not just those named in identity: deploy.php files
      # in other repos pin these paths.
      home.file = lib.mapAttrs' (
        file: _: lib.nameValuePair ".ssh/${file}" { source = ./. + "/${file}"; }
      ) (lib.filterAttrs (file: _: lib.hasSuffix ".pub" file) (builtins.readDir ./.));
    };
}
