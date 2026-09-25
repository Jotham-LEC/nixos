let
  username = "jothamlec";
in
{
  flake.modules.nixos.default =
    { config, identity, ... }:
    {
      _module.args.username = username;

      sops.secrets."passwords/${username}".neededForUsers = true;
      sops.secrets."passwords/root".neededForUsers = true;

      users.mutableUsers = false;

      users.users.${username} = {
        isNormalUser = true;
        description = identity.fullName;
        hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
        ];
      };

      users.users."root".hashedPasswordFile = config.sops.secrets."passwords/root".path;
    };

  flake.modules.homeManager.default = {
    _module.args.username = username;

    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "26.11";
    programs.home-manager.enable = true;
  };
}
