{
  flake.modules.nixos.default = {
    hardware.bluetooth.enable = true;
    # BlueZ experimental LE features: the MX Keys reconnects reliably after
    # resume, and reports its battery level.
    hardware.bluetooth.settings.General.Experimental = true;
  };

  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bluetui ];
    };
}
