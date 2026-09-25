{
  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      palette,
      ...
    }:
    let
      tesseract = pkgs.tesseract.override {
        enableLanguages = [
          "eng"
          "chi_sim"
        ];
      };

      mkScript =
        name: runtimeInputs:
        pkgs.writeShellApplication {
          inherit name runtimeInputs;
          text = builtins.readFile (./bin + "/${name}.sh");
        };

      scripts = [
        (mkScript "clip-paste" [ pkgs.wl-clipboard ])
        (mkScript "clip-history" [
          pkgs.cliphist
          pkgs.coreutils
          pkgs.libnotify
          pkgs.rofi
          pkgs.wl-clipboard
        ])
        (mkScript "display-mirror" [
          config.wayland.windowManager.sway.package
          pkgs.jq
          pkgs.libnotify
          pkgs.procps
          pkgs.util-linux
          pkgs.wl-mirror
        ])
        (mkScript "screen-ocr" [
          pkgs.grim
          pkgs.libnotify
          pkgs.slurp
          tesseract
          pkgs.wl-clipboard
        ])
        (mkScript "screenshot" [
          pkgs.coreutils
          pkgs.grim
          pkgs.libnotify
          pkgs.slurp
          pkgs.wl-clipboard
        ])
        (mkScript "type-text" [
          pkgs.bash
          pkgs.coreutils
          pkgs.libnotify
          pkgs.util-linux
          pkgs.wtype
        ])
      ];
    in
    {
      home.packages =
        scripts
        ++ builtins.attrValues {
          inherit (pkgs)
            rofi
            rofimoji
            wl-clipboard
            wtype
            grim
            slurp
            libnotify
            ;
        };

      xdg.configFile."rofi/config.rasi".source = ./rofi.rasi;

      xdg.configFile."rofi/colors.rasi".text = with palette.colors; ''
        * {
            bg:      ${bg};
            bg-alt:  ${bgAlt};
            fg:      ${fg};
            fg-dim:  ${dim};
            accent:  ${blue};
            sel-bg:  ${selection};
            sel-fg:  ${yellow};
            line:    ${selection};
            green:   ${green};
            red:     ${red};

            background-color: transparent;
            text-color:       @fg;
        }
      '';
    };
}
