{
  flake.modules.nixos.default = {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wiremix ];
    };
}
