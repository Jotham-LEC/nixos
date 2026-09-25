let
  colors = {
    bg = "#1d2021";
    bgAlt = "#3c3836";
    selection = "#504945";
    muted = "#665c54";
    dim = "#bdae93";
    fg = "#d5c4a1";
    fgBright = "#ebdbb2";
    fgBrightest = "#fbf1c7";

    red = "#fb4934";
    orange = "#fe8019";
    yellow = "#fabd2f";
    green = "#b8bb26";
    cyan = "#8ec07c";
    blue = "#83a598";
    purple = "#d3869b";
  };

  palette = {
    inherit colors;
    hex = builtins.mapAttrs (_: c: builtins.substring 1 6 c) colors;

    fonts = {
      mono = "Aporetic Sans Mono";
      sans = "Noto Sans";
      serif = "Noto Serif";
      emoji = "Noto Color Emoji";
      symbols = "Symbols Nerd Font Mono";

      sizes = {
        terminal = 20;
        desktop = 14;
        bar = 14;
      };
    };
  };
in
{
  flake.modules.nixos.default = {
    _module.args.palette = palette;
  };
  flake.modules.homeManager.default = {
    _module.args.palette = palette;
  };
}
