{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      palette,
      ...
    }:
    {
      services.dunst = {
        enable = true;
        iconTheme = {
          inherit (config.gtk.iconTheme) name package;
          size = "48x48";
        };
        settings = {
          global = {
            markup = "full";
            format = "<b>%s</b>\\n%b";
            alignment = "left";
            vertical_alignment = "center";
            word_wrap = true;
            ignore_newline = false;

            origin = "top-right";
            offset = "(10, 10)";
            width = 400;
            height = "(0, 400)";
            notification_limit = 5;
            gap_size = 6;
            padding = 12;
            horizontal_padding = 12;
            corner_radius = 4;
            frame_width = 2;

            font = "${palette.fonts.sans} ${toString palette.fonts.sizes.desktop}";
            separator_color = palette.colors.selection;

            icon_position = "left";
            min_icon_size = 24;
            max_icon_size = 48;
            enable_recursive_icon_lookup = true;
            icon_theme = config.gtk.iconTheme.name;

            stack_duplicates = true;
            hide_duplicate_count = false;
            show_indicators = false;
            sticky_history = true;
            history_length = 50;
            idle_threshold = 0;

            mouse_left_click = "do_action, close_current";
            mouse_middle_click = "context";
            mouse_right_click = "close_current";
          };

          urgency_low = {
            timeout = 4;
            background = palette.colors.bgAlt;
            foreground = palette.colors.fg;
            frame_color = palette.colors.muted;
          };
          urgency_normal = {
            timeout = 8;
            background = palette.colors.bgAlt;
            foreground = palette.colors.fg;
            frame_color = palette.colors.blue;
          };
          urgency_critical = {
            timeout = 15;
            background = palette.colors.bgAlt;
            foreground = palette.colors.fg;
            frame_color = palette.colors.red;
          };

          feishu = lib.hm.dag.entryAfter [ "urgency_critical" "urgency_low" "urgency_normal" ] {
            appname = "Feishu";
            timeout = 0;
          };
        };
      };
    };
}
