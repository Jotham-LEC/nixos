{
  flake.modules.homeManager.default = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";

        "application/pdf" = "firefox.desktop";

        "image/jpeg" = "firefox.desktop";
        "image/png" = "firefox.desktop";
        "image/gif" = "firefox.desktop";
        "image/webp" = "firefox.desktop";
        "image/bmp" = "firefox.desktop";
        "image/avif" = "firefox.desktop";
        "image/svg+xml" = "firefox.desktop";
        "image/vnd.microsoft.icon" = "firefox.desktop";

        "x-scheme-handler/mailto" = "emacsclient-mail.desktop";

        "inode/directory" = "thunar.desktop";

        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/mpeg" = "mpv.desktop";
        "video/x-flv" = "mpv.desktop";
        "video/x-ms-wmv" = "mpv.desktop";
        "video/ogg" = "mpv.desktop";
        "video/3gpp" = "mpv.desktop";
      };
    };
  };
}
