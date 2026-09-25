{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          ffmpeg
          ghostscript
          imagemagick
          krita
          mpv
          obs-studio
          sidequest
          ;
        inherit (pkgs.kdePackages) kdenlive;
      };
    };
}
