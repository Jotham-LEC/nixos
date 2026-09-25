{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages =
        builtins.attrValues {
          inherit (pkgs)
            cmake
            gcc
            gnumake
            libtool
            nodejs
            pipenv
            ;
        }
        ++ [
          (pkgs.php.buildEnv {
            extensions = { all, enabled }: enabled ++ [ all.xdebug ];
            extraConfig = ''
              xdebug.mode=debug
              xdebug.start_with_request=trigger
              xdebug.client_port=9003
            '';
          })

          pkgs.phpPackages.composer
          (pkgs.python3.withPackages (
            ps:
            builtins.attrValues {
              inherit (ps)
                black
                isort
                pyflakes
                pytest
                ;
            }
          ))
        ];
    };
}
