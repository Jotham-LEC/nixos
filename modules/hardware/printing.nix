{
  flake.modules.nixos.default = {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
