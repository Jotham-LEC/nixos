let
  sharedExtensions = {
    unhook-youtuber = "khncfooichmfjbepaaaebmommgaepoid";
    onepassword = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
  };
  ublock-origin-lite = "ddkjiahejlhfcafbddmgiahcphecmpfh";
in
{
  flake.modules.homeManager.default = {
    programs.brave-origin = {
      enable = true;
      extensions = builtins.attrValues sharedExtensions;
    };
    programs.chromium = {
      enable = true;
      extensions = builtins.attrValues (sharedExtensions // { inherit ublock-origin-lite; });
    };

    programs.firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableMasterPasswordCreation = true;
        DisableSetDesktopBackground = true;
        DisablePocket = true;
        HardwareAcceleration = true;
        Preferences = {
          "media.ffmpeg.vaapi.enabled" = {
            Value = true;
            Status = "default";
          };
          "media.hardware-video-decoding.force-enabled" = {
            Value = true;
            Status = "default";
          };
          "gfx.webrender.all" = {
            Value = true;
            Status = "default";
          };
        };
        OfferToSaveLogins = false;
        Homepage.StartPage = "previous-session";
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "myallychou@gmail.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
            installation_mode = "force_installed";
          };
          "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/gruvbox-dark-theme/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
    home.sessionVariables = {
      BROWSER = "firefox";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
