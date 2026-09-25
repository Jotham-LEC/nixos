{
  flake.modules.nixos.default = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 5;
    boot.loader.systemd-boot.editor = false;
    boot.loader.efi.canTouchEfiVariables = true;

    # Nothing here expects /tmp to survive a reboot, and letting it accumulate
    # costs a 15s systemd-tmpfiles-clean run on every boot to age files out one
    # at a time. A fresh mount does the same job for free.
    boot.tmp.cleanOnBoot = true;
  };
}
