{
  flake.modules.nixos.default = {
    hardware.enableRedistributableFirmware = true;
    services.fwupd.enable = true;
  };
}
