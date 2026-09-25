{ inputs, ... }:
let
  unfree = [
    "1password"
    "1password-cli"
    "beeper"
    "claude-code"
    "corefonts"
    "feishu"
    "intelephense"
    "symbola"
    "vista-fonts"
    "vista-fonts-chs"
  ];
  nixpkgsConfig = {
    allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) unfree;
  };
in
{
  flake.modules.nixos.default.nixpkgs.config = nixpkgsConfig;

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      };
    };
}
