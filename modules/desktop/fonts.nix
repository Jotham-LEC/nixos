{
  flake.modules.nixos.default =
    { pkgs, palette, ... }:
    {
      fonts.packages =
        builtins.attrValues {
          inherit (pkgs)
            aporetic
            noto-fonts
            noto-fonts-color-emoji
            inter
            excalifont
            symbola
            corefonts
            vista-fonts
            vista-fonts-chs
            ;
          inherit (pkgs.nerd-fonts) symbols-only;
        }
        ++ [
          (pkgs.google-fonts.override {
            fonts = [
              "Manrope"
              "Mulish"
              "Montserrat"
              "Bebas Neue"
              "Roboto"
              "Open Sans"
              "Lato"
              "Prompt"
              "Fira Sans"
              "Raleway"
              "Kanit"
            ];
          })
        ];

      fonts.fontconfig.defaultFonts = {
        monospace = [ palette.fonts.mono ];
        sansSerif = [ palette.fonts.sans ];
        serif = [ palette.fonts.serif ];
        emoji = [ palette.fonts.emoji ];
      };
    };
}
