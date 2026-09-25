{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.git ];
    };

  flake.modules.homeManager.default =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      primaryMail = lib.findFirst (a: a.primary) null (lib.attrValues config.accounts.email.accounts);

      git-relink = pkgs.writeShellApplication {
        name = "git-relink";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.gh
          pkgs.git
        ];
        text = builtins.readFile ./git-relink.sh;
      };
    in
    {
      programs.git = {
        enable = true;
        package = null;
        lfs.enable = true;

        signing = {
          key = lib.removeSuffix "\n" (builtins.readFile ../system/ssh/jothamlec.pub);
          format = "ssh";
          signByDefault = true;
          signer = lib.getExe' osConfig.programs._1password-gui.package "op-ssh-sign";
        };

        settings = {
          user = {
            name = primaryMail.realName;
            email = primaryMail.address;
          };

          credential = {
            "https://github.com".helper = "!${lib.getExe pkgs.gh} auth git-credential";
            "https://gist.github.com".helper = "!${lib.getExe pkgs.gh} auth git-credential";
          };
        };
      };

      home.packages = [
        pkgs.gh
        git-relink
      ];
    };
}
