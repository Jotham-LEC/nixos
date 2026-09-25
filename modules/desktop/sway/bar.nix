{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      palette,
      ...
    }:
    let
      inherit (palette.colors)
        bgAlt
        muted
        dim
        fg
        red
        orange
        yellow
        green
        blue
        purple
        ;
    in
    {
      xdg.configFile."i3status/config".onChange = ''
        for sock in ''${XDG_RUNTIME_DIR:-/run/user/$UID}/sway-ipc.$UID.*.sock; do
          [ -S "$sock" ] &&
            ${lib.getExe' config.wayland.windowManager.sway.package "swaymsg"} -s "$sock" reload >/dev/null 2>&1 || true
        done
      '';

      wayland.windowManager.sway.config.bars = [
        {
          position = "bottom";
          statusCommand = "i3status";
          trayOutput = "none";

          fonts = {
            names = [
              palette.fonts.mono
              palette.fonts.symbols
            ];
            size = toString palette.fonts.sizes.bar;
          };

          colors = {
            background = bgAlt;
            statusline = fg;
            separator = muted;
            focusedWorkspace = {
              border = bgAlt;
              background = blue;
              text = fg;
            };
            activeWorkspace = {
              border = bgAlt;
              background = muted;
              text = fg;
            };
            inactiveWorkspace = {
              border = bgAlt;
              background = muted;
              text = fg;
            };
            urgentWorkspace = {
              border = bgAlt;
              background = red;
              text = fg;
            };
            bindingMode = {
              border = bgAlt;
              background = red;
              text = fg;
            };
          };

          extraConfig = ''
            binding_mode_indicator yes
            separator_symbol "·"
          '';
        }
      ];

      programs.i3status = {
        enable = true;
        general = {
          markup = "pango";
          color_good = fg;
          color_degraded = dim;
          color_bad = red;
        };
        modules = {
          ipv6.enable = false;
          "ethernet _first_".enable = false;
          "disk /".enable = false;
          load.enable = false;
          memory.enable = false;

          # Flag file written by xdg-desktop-portal-wlr in sway.nix.
          "read_file screenshare" = {
            position = 0;
            settings = {
              path = "~/.cache/screenshare-active";
              format = "<span foreground='${red}'></span> sharing";
              format_bad = "";
            };
          };
          "wireless _first_".settings = {
            format_up = "<span foreground='${blue}'></span> %essid";
            format_down = " offline";
          };
          "volume master" = {
            position = 3;
            settings = {
              device = "pulse";
              format = "<span foreground='${purple}'></span> %volume";
              format_muted = " muted";
            };
          };
          "battery all".settings = {
            format = "%status %percentage";
            format_percentage = "%.00f%s";
            last_full_capacity = true;
            low_threshold = 20;
            threshold_type = "percentage";
            status_chr = "<span foreground='${yellow}'></span>";
            status_bat = "<span foreground='${green}'></span>";
            status_full = "<span foreground='${green}'></span>";
            status_idle = "<span foreground='${green}'></span>";
            status_unk = "<span foreground='${dim}'></span>";
          };
          "tztime local".settings.format =
            "<span foreground='${orange}'></span> %a %-d <span foreground='${orange}'></span> %H:%M";
        };
      };
    };
}
