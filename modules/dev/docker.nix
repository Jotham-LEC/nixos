{
  flake.modules.nixos.default =
    { username, ... }:
    {
      virtualisation.docker.enable = true;
      # Tailscale leaves only MagicDNS in resolv.conf, which Docker 29 discards as
      # an internal resolver, leaving containers with no upstream (EAI_AGAIN).
      # MagicDNS first so tailnet names resolve; 1.1.1.1 for when Tailscale is down.
      virtualisation.docker.daemon.settings.dns = [
        "100.100.100.100"
        "1.1.1.1"
      ];

      users.users.${username}.extraGroups = [ "docker" ];
    };
}
