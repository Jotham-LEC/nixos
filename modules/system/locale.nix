{
  flake.modules.nixos.default = {
    time.timeZone = "Asia/Kuala_Lumpur";
    i18n.extraLocaleSettings = {
      LC_MONETARY = "ms_MY.UTF-8";
      LC_PAPER = "ms_MY.UTF-8";
    };
  };
}
