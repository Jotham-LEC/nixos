{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  flake.modules.nixos.default.nixpkgs.overlays = [ inputs.self.overlays.default ];

  perSystem =
    { config, pkgs, ... }:
    {
      overlayAttrs = config.packages;

      packages = {
        lark-cli = pkgs.callPackage ../../pkgs/lark-cli.nix { };
        laravel-cloud-cli = pkgs.callPackage ../../pkgs/laravel-cloud-cli.nix { };
        laravel-lsp = pkgs.callPackage ../../pkgs/laravel-lsp.nix { };
        siteone-crawler = pkgs.callPackage ../../pkgs/siteone-crawler.nix { };
      };
    };
}
