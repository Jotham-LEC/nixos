{
  flake.modules.nixos.default.programs.localsend = {
    enable = true;
    # The module's default opens 53317/tcp+udp on *every* interface, café wifi
    # included, for a feature only ever used on a trusted LAN. Re-enable (or add
    # a scoped rule) on the day a transfer actually needs to reach this laptop.
    openFirewall = false;
  };

  flake.modules.homeManager.default =
    { pkgs, osConfig, ... }:
    let
      # Beeper's FHS sandbox symlinks /etc/localtime to a path with no
      # zoneinfo/<zone> in it, so Chromium can't detect the zone and falls back
      # to UTC. An explicit TZ skips detection, and bwrap passes it through.
      beeper-tz = pkgs.symlinkJoin {
        name = "beeper-tz";
        paths = [ pkgs.beeper ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/beeper \
            --set-default TZ "${osConfig.time.timeZone}" \
            --add-flags "--password-store=gnome-libsecret"
        '';
      };
    in
    {
      home.packages = [
        beeper-tz
        pkgs.feishu
      ];
    };
}
