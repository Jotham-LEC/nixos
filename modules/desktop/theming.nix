{
  flake.modules.nixos.default =
    { palette, ... }:
    {
      console.colors = with palette.hex; [
        bg
        red
        green
        yellow
        blue
        purple
        cyan
        fg
        muted
        orange
        green
        yellow
        blue
        purple
        cyan
        fgBrightest
      ];
    };

  flake.modules.homeManager.default =
    { pkgs, palette, ... }:
    {
      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = "Gruvbox-Plus-Dark";
          package = pkgs.gruvbox-plus-icons;
        };
        font = {
          name = palette.fonts.sans;
          size = palette.fonts.sizes.desktop;
        };
        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
      };

      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      home.pointerCursor = {
        enable = true;
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 30;
        gtk.enable = true;
        sway.enable = true;
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
      };
    };
}
