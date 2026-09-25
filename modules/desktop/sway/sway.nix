{
  flake.modules.nixos.default =
    { lib, pkgs, ... }:
    let
      pkill = lib.getExe' pkgs.procps "pkill";
    in
    {
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = [ ];
      };

      # The portal's systemd PATH can't see user-profile launchers, so its
      # default chooser finds nothing and browsers fall back to tab-only sharing.
      xdg.portal.wlr.settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${lib.getExe pkgs.slurp} -f %o -or";
        # Flag file read by the i3status block in bar.nix; USR1 redraws it now.
        exec_before = "touch $HOME/.cache/screenshare-active; ${pkill} -USR1 -x i3status";
        exec_after = "rm -f $HOME/.cache/screenshare-active; ${pkill} -USR1 -x i3status";
      };
      # Casts die with the portal, so a flag left by a crash is stale.
      systemd.user.services.xdg-desktop-portal-wlr.serviceConfig.ExecStartPre =
        "${lib.getExe' pkgs.coreutils "rm"} -f %h/.cache/screenshare-active";

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
    };

  flake.modules.homeManager.default =
    { lib, pkgs, ... }:
    {
      wayland.systemd.target = "sway-session.target";

      wayland.windowManager.sway = {
        enable = true;
        checkConfig = true;

        config.input = {
          "type:keyboard" = {
            xkb_options = "ctrl:nocaps";
            repeat_delay = "250";
            repeat_rate = "30";
          };
          "type:pointer" = {
            accel_profile = "adaptive";
            pointer_accel = "-0.15";
            natural_scroll = "disabled";
            middle_emulation = "enabled";
          };
          # Middle-button scrolling on the TrackPoint overshoots at libinput's
          # default rate. Scoped to the nub so a plugged-in mouse keeps 1.0.
          "2:10:TPPS/2_Elan_TrackPoint".scroll_factor = "0.5";
          "type:touchpad" = {
            accel_profile = "adaptive";
            tap = "disabled";
            natural_scroll = "enabled";
            dwt = "enabled";
            click_method = "clickfinger";
          };
        };
      };

      services.lxqt-policykit-agent.enable = true;
      services.cliphist.enable = true;

      systemd.user.services.lxqt-policykit-agent = {
        Unit.PartOf = lib.mkForce [ "sway-session.target" ];
        Install.WantedBy = lib.mkForce [ "sway-session.target" ];
      };

      systemd.user.services.wayscriber = {
        Unit = {
          Description = "Wayscriber screen annotation daemon";
          PartOf = [ "sway-session.target" ];
          After = [ "sway-session.target" ];
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.wayscriber} --daemon --no-tray";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

      home.packages = builtins.attrValues {
        inherit (pkgs)
          brightnessctl
          cliphist
          hyprpicker
          playerctl
          wayscriber
          wdisplays
          wl-mirror
          woomer
          ;
      };
    };
}
