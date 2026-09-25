{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          config.formatter
        ]
        ++ builtins.attrValues {
          inherit (pkgs)
            age
            nix-update
            shellcheck
            shfmt
            sops
            ssh-to-age
            ;
        };
      };
    };
}
