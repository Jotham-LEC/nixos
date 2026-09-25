{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        extraPackages = builtins.attrValues {
          inherit (pkgs)
            intel-compute-runtime
            intel-media-driver
            ;
        };
      };
      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    };
}
