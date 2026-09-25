{
  flake.modules.nixos.default =
    { config, username, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "${config.users.users.${username}.home}/Projects/nixos";
        clean = {
          enable = true;
          extraArgs = "--keep 5 --keep-since 30d";
        };
      };
    };
}
