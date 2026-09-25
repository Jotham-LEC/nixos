{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      palette,
      ...
    }:
    let
      swaylock = lib.getExe config.programs.swaylock.package;
    in
    {
      programs.swaylock = {
        enable = true;
        settings = with palette.hex; {
          ignore-empty-password = true;
          show-failed-attempts = true;
          indicator-caps-lock = true;

          color = bg;
          inside-color = bg;
          inside-caps-lock-color = bg;
          inside-clear-color = bg;
          inside-ver-color = bg;
          inside-wrong-color = bg;
          ring-color = bgAlt;
          ring-caps-lock-color = bgAlt;
          ring-clear-color = red;
          ring-ver-color = green;
          ring-wrong-color = red;
          key-hl-color = green;
          text-color = fg;
          layout-bg-color = bg;
          layout-border-color = bgAlt;
          layout-text-color = fg;
          separator-color = "00000000";
          line-uses-inside = true;
        };
      };

      services.swayidle = {
        enable = true;
        events = {
          lock = "${swaylock} -f";
          before-sleep = "${swaylock} -f";
        };
        timeouts = [
          {
            timeout = 600;
            command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
          }
        ];
      };
    };
}
