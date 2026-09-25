{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          prismlauncher
          ;
      };
    };
}
