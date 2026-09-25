{
  flake.modules.homeManager.default =
    { pkgs, palette, ... }:
    {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          btop
          fd
          file
          jq
          ripgrep
          tealdeer
          tree
          vim
          ;
      };

      programs.zoxide.enable = true;

      programs.fzf = {
        enable = true;
        colors = with palette.colors; {
          bg = bg;
          "bg+" = bgAlt;
          fg = dim;
          "fg+" = fgBright;
          header = blue;
          hl = blue;
          "hl+" = blue;
          info = yellow;
          marker = cyan;
          pointer = cyan;
          prompt = yellow;
          spinner = cyan;
        };
      };

      programs.foot = {
        enable = true;
        settings = with palette.hex; {
          main = {
            font = "${palette.fonts.mono}:size=${toString palette.fonts.sizes.terminal}";
            pad = "12x12";
            selection-target = "clipboard";
          };

          mouse.hide-when-typing = "yes";

          colors-dark = {
            background = bg;
            foreground = fg;
            cursor = "${bg} ${fg}";
            selection-foreground = fg;
            selection-background = selection;
            urls = blue;

            regular0 = bg;
            bright0 = muted;
            regular1 = red;
            bright1 = red;
            regular2 = green;
            bright2 = green;
            regular3 = yellow;
            bright3 = yellow;
            regular4 = blue;
            bright4 = blue;
            regular5 = purple;
            bright5 = purple;
            regular6 = cyan;
            bright6 = cyan;
            regular7 = fg;
            bright7 = fgBrightest;
          };
        };
      };
    };
}
