{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
