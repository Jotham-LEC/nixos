{
  flake.modules.homeManager.default =
    { palette, ... }:
    let
      mod = "Mod4";
      term = "foot";
    in
    {
      wayland.windowManager.sway = {
        config = {
          modifier = mod;
          fonts = {
            names = [ palette.fonts.sans ];
            size = palette.fonts.sizes.desktop * 1.0;
          };
          colors =
            let
              inherit (palette.colors)
                bg
                fg
                muted
                blue
                red
                green
                ;
              scheme = border: {
                inherit border;
                background = bg;
                text = fg;
                indicator = green;
                childBorder = border;
              };
            in
            {
              background = bg;
              focused = scheme blue;
              focusedInactive = scheme muted;
              unfocused = scheme muted;
              urgent = scheme red;
              placeholder = scheme muted;
            };
          floating.modifier = mod;
          defaultWorkspace = "workspace number 1";
          window = {
            titlebar = false;
            hideEdgeBorders = "smart";
            commands = [
              {
                criteria.app_id = "(?i)wdisplays";
                command = "floating enable, resize set 800 600";
              }
              {
                criteria.app_id = "(?i)fcitx5-config-qt";
                command = "floating enable";
              }
              {
                criteria.class = "(?i)fcitx5-config-qt";
                command = "floating enable";
              }
              {
                criteria.app_id = "(?i)thunar";
                command = "floating enable";
              }
              {
                criteria = {
                  app_id = "^emacs$";
                  title = "^(emacs-everywhere|Emacs Everywhere :: )";
                };
                command = "floating enable";
              }
              {
                criteria.title = "^Picture-in-Picture$";
                command = "floating enable, sticky enable";
              }
              {
                criteria.app_id = ".*";
                command = "inhibit_idle fullscreen";
              }
              {
                criteria.class = ".*";
                command = "inhibit_idle fullscreen";
              }
            ];
          };

          gaps = {
            inner = 10;
            outer = 5;
            smartGaps = true;
            smartBorders = "no_gaps";
          };

          focus = {
            followMouse = true;
            mouseWarping = true;
          };

          keybindings = {
            "${mod}+Return" = "exec ${term}";
            "${mod}+d" = "exec rofi -show drun -p App";
            "${mod}+q" = "kill";
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+n" = "exec dunstctl history-pop";

            # --release so wtype's characters don't arrive as Super chords; the
            # "nop" stops sway forwarding the keydown to the focused window.
            "${mod}+t" = "nop";
            "${mod}+Shift+t" = "nop";
            "--release ${mod}+t" = ''exec type-text "$(date +%Y-%m-%d)"'';
            "--release ${mod}+Shift+t" = ''exec type-text "$(date +%Y%m%dT%H%M%S)"'';

            "${mod}+Escape" = "exec loginctl lock-session";

            "${mod}+i" = ''exec emacsclient --eval "(emacs-everywhere)"'';

            "${mod}+v" = "exec clip-history";
            "${mod}+grave" = "exec fcitx5-remote -t";

            "${mod}+Shift+p" = "exec screenshot";
            "${mod}+Shift+i" = "exec hyprpicker -a -n";
            # Swallows Feishu's global screenshot hotkey.
            "Control+Shift+a" = "nop";

            "${mod}+Shift+o" = "exec screen-ocr";
            "${mod}+z" = "exec woomer";
            "${mod}+w" = "exec wayscriber --daemon-toggle";

            "${mod}+period" =
              "exec rofimoji --selector rofi --typer wtype --clipboarder wl-copy --action type copy --skin-tone neutral --prompt Emoji";

            "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioMicMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            "XF86AudioPrev" = "exec playerctl previous";
            "XF86AudioPlay" = "exec playerctl play-pause";
            "XF86AudioNext" = "exec playerctl next";
            "${mod}+Left" = "exec playerctl previous";
            "${mod}+Down" = "exec playerctl play-pause";
            "${mod}+Right" = "exec playerctl next";
            "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl --quiet -n set +5%";
            "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl --quiet -n set 5%-";
            "XF86Display" = "exec display-mirror";
            "XF86Favorites" = "exec dunstctl set-paused toggle";

            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";

            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";

            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";
            "${mod}+0" = "workspace number 10";

            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";
            "${mod}+Shift+0" = "move container to workspace number 10";

            "${mod}+e" = "layout toggle splith splitv tabbed";
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+space" = "floating toggle";

            "${mod}+r" = ''mode "resize"'';
            "${mod}+Shift+q" = ''mode "power"'';
          };

          modes = {
            resize = {
              h = "resize shrink width 20px";
              j = "resize grow   height 20px";
              k = "resize shrink height 20px";
              l = "resize grow   width 20px";
              Return = ''mode "default"'';
              Escape = ''mode "default"'';
            };

            power = {
              k = ''mode "default", exec --no-startup-id loginctl lock-session'';
              l = "exec --no-startup-id swaymsg exit";
              s = ''mode "default", exec --no-startup-id systemctl suspend'';
              r = ''mode "default", exec --no-startup-id systemctl reboot'';
              p = ''mode "default", exec --no-startup-id systemctl poweroff'';
              Return = ''mode "default"'';
              Escape = ''mode "default"'';
            };
          };

          startup = [
            {
              command = "solaar --window=hide";
            }
            {
              command = "fcitx5 -d --replace";
            }
            {
              command = "1password --silent";
            }
          ];
        };

        extraConfig = ''
          title_align center
          popup_during_fullscreen smart
          focus_wrapping yes
        '';
      };
    };
}
