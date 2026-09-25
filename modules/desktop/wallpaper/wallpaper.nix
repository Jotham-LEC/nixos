{ inputs, ... }:
{
  flake.modules.homeManager.default =
    {
      lib,
      pkgs,
      palette,
      ...
    }:
    {
      imports = [ inputs.greyline.homeManagerModules.default ];

      services.greyline = {
        enable = true;
        backend = "swww";
        swwwPackage = pkgs.awww;
        settings = {
          map_style = "vector";
          theme = "gruvbox";
          format = "24h";
          font_family = palette.fonts.mono;
          font_scale = 0.85;
          bar_height = 115;
          logo_path = "${./thinkpad_logo.png}";
          logo_invert = true;
          twilight = {
            bands = true;
            darkness = "subtle";
          };
          home = {
            tz = "auto";
            column_highlight = true;
          };
          city = [
            {
              name = "San Francisco";
              lat = 37.77;
              lon = -122.42;
              tz = "America/Los_Angeles";
              label_side = "below";
            }
            {
              name = "Chicago";
              lat = 41.88;
              lon = -87.63;
              tz = "America/Chicago";
            }
            {
              name = "New York";
              lat = 40.71;
              lon = -74.01;
              tz = "America/New_York";
            }
            {
              name = "London";
              lat = 51.51;
              lon = -0.13;
              tz = "Europe/London";
            }
            {
              name = "Dubai";
              lat = 25.20;
              lon = 55.27;
              tz = "Asia/Dubai";
            }
            {
              name = "New Delhi";
              lat = 28.61;
              lon = 77.21;
              tz = "Asia/Kolkata";
            }
            {
              name = "Jakarta";
              lat = -6.21;
              lon = 106.85;
              tz = "Asia/Jakarta";
            }
            {
              name = "Kuala Lumpur";
              lat = 3.14;
              lon = 101.69;
              tz = "Asia/Kuala_Lumpur";
              label_side = "left";
            }
            {
              name = "Beijing";
              lat = 39.90;
              lon = 116.41;
              tz = "Asia/Shanghai";
            }
            {
              name = "Tokyo";
              lat = 35.68;
              lon = 139.69;
              tz = "Asia/Tokyo";
            }
            {
              name = "Sydney";
              lat = -33.87;
              lon = 151.21;
              tz = "Australia/Sydney";
            }
          ];
        };
      };

      systemd.user.timers.greyline = {
        Unit.PartOf = [ "sway-session.target" ];
        Install.WantedBy = lib.mkForce [ "sway-session.target" ];
      };
    };
}
