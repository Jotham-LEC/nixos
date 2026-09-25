# Placeholder identity. scripts/publish.sh copies this over modules/identity.nix
# so the published tree still evaluates with nothing personal left in it.
# Every `key` points at the committed example.pub, whose private half never existed.
let
  identity = {
    realName = "Ada Lovelace";
    fullName = "Augusta Ada King";

    diskById = "nvme-SOMEVENDOR_SOMEMODEL_SERIAL0123456789";

    mail = {
      personal = {
        address = "ada@example.com";
        aliases = [ "ada.lovelace@example.com" ];
        primary = true;
        key = "p";
        signature = "Ada Lovelace";
      };
      work = {
        address = "ada@work.example.com";
        key = "w";
        signature = ''
          Ada Lovelace
          Analyst
          Example Ltd'';
      };
    };

    projectRoots = { };

    vaults = [
      "Personal"
      "Work"
    ];

    hosts = {
      web = {
        user = "root";
        key = "example";
      };
      db = {
        user = "deploy";
        key = "example";
      };
    };

    forgejo = {
      host = "git.example.com";
      user = "git";
      key = "example";
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKT7H8GNLl+xt0dZN+SzPosQNBTaEaMmjTT9THpf2WAY";
    };
  };
in
{
  flake.modules.nixos.default._module.args.identity = identity;
  flake.modules.homeManager.default._module.args.identity = identity;
}
