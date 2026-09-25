{
  flake.modules.nixos.default = {
    services.gvfs.enable = true;
  };
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bashmount ];
    };
}
