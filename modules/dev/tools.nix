{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          dbeaver-bin
          laravel-cloud-cli
          lark-cli
          siteone-crawler
          ;
      };
    };
}
