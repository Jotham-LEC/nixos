{
  flake.modules.nixos.default = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.settings.min-free = 5 * 1024 * 1024 * 1024;
    nix.settings.max-free = 20 * 1024 * 1024 * 1024;
  };
}
