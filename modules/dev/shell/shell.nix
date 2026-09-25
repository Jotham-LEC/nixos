{
  flake.modules.nixos.default =
    { pkgs, username, ... }:
    {
      programs.zsh.enable = true;
      users.users.${username}.shell = pkgs.zsh;
    };

  flake.modules.homeManager.default =
    {
      pkgs,
      config,
      lib,
      palette,
      identity,
      ...
    }:
    let
      editor = pkgs.writeShellScript "editor" ''
        exec emacsclient -t -a "" "$@"
      '';
    in
    {
      programs.zsh = {
        enable = true;
        autocd = true;

        history = {
          size = 50000;
          save = 50000;
        };

        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          dep = "vendor/bin/dep";
          mirror = "mpv av://v4l2:/dev/video0 --demuxer-lavf-o=video_size=1280x720,input_format=mjpeg,framerate=30 --hwdec=auto --profile=low-latency --untimed";
        };

        initContent = ''
          setopt HIST_REDUCE_BLANKS HIST_VERIFY EXTENDED_GLOB NO_BEEP INTERACTIVE_COMMENTS
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
        '';
      };

      programs.starship = {
        enable = true;
        settings = {
          palette = "gruvbox";
          palettes.gruvbox = with palette.colors; {
            black = bg;
            red = red;
            green = green;
            yellow = yellow;
            blue = blue;
            purple = purple;
            cyan = cyan;
            white = fg;
            bright-black = muted;
            bright-red = orange;
            bright-green = green;
            bright-yellow = yellow;
            bright-blue = blue;
            bright-purple = purple;
            bright-cyan = cyan;
            bright-white = fgBrightest;
          };
        };
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
        enableZshIntegration = true;
      };

      home.sessionVariables = {
        EDITOR = editor;
        VISUAL = editor;
      }
      // lib.mapAttrs (_: path: "${config.home.homeDirectory}/${path}") identity.projectRoots;
    };
}
