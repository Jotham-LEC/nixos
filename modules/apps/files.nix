{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      programs.thunar = {
        enable = true;
        plugins = builtins.attrValues {
          inherit (pkgs)
            thunar-volman
            thunar-archive-plugin
            thunar-media-tags-plugin
            ;
        };
      };
    };

  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          zip
          unzip
          p7zip
          trash-cli
          unar
          pika-backup
          ;
      };

      xdg.configFile."baloofilerc".text = ''
        [Basic Settings]
        Indexing-Enabled=false
      '';
    };
}
