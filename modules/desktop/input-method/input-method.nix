{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = builtins.attrValues {
          inherit (pkgs) fcitx5-gtk;
          inherit (pkgs.qt6Packages) fcitx5-chinese-addons fcitx5-configtool;
        };
      };
    };

  flake.modules.homeManager.default = {
    xdg.configFile."fcitx5/profile".source = ./fcitx5/profile;
    xdg.configFile."fcitx5/config".source = ./fcitx5/config;
    xdg.configFile."fcitx5/conf/clipboard.conf".source = ./fcitx5/conf/clipboard.conf;
  };
}
