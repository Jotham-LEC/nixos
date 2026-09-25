{
  flake.modules.nixos.default = {
    hardware.logitech.wireless.enable = true;
    programs.solaar.enable = true;
  };
}
