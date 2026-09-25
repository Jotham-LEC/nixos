{ inputs, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      formatter = pkgs.treefmt.withConfig {
        name = "treefmt-nixos";
        runtimeInputs = [
          pkgs.deadnix
          pkgs.nixfmt
          pkgs.shellcheck
          pkgs.shfmt
        ];
        settings = {
          on-unmatched = "info";
          excludes = [ "hosts/x1c/hardware-configuration.nix" ];
          formatter.deadnix = {
            command = "deadnix";
            options = [ "--edit" ];
            includes = [ "*.nix" ];
            priority = 1;
          };
          formatter.nixfmt = {
            command = "nixfmt";
            includes = [ "*.nix" ];
            priority = 2;
          };
          formatter.shfmt = {
            command = "shfmt";
            options = [ "-w" ];
            includes = [ "*.sh" ];
            priority = 1;
          };
          formatter.shellcheck = {
            command = "shellcheck";
            options = [ "--shell=bash" ];
            includes = [ "*.sh" ];
            priority = 2;
          };
        };
      };

      checks.formatting = config.formatter.check inputs.self;
    };
}
