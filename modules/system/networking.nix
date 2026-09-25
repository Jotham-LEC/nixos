{
  flake.modules.nixos.default = {
    networking.networkmanager.enable = true;
    services.tailscale.enable = true;
    # Both for session startup. glibc waits 5s on an unresponsive nameserver
    # before trying the next; nsncd answers every NSS lookup (users and groups
    # too, not just hosts) with 8 workers by default, so a burst of slow DNS at
    # login can starve local lookups behind it.
    networking.resolvconf.extraOptions = [ "timeout:1" ];
    systemd.services.nscd.environment.NSNCD_WORKER_COUNT = "64";
  };
}
