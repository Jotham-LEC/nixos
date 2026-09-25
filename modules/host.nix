{ inputs, ... }:
{
  flake.nixosConfigurations.x1c = inputs.nixpkgs.lib.nixosSystem {
    system = null;
    modules = [
      ../hosts/x1c/hardware-configuration.nix
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      ../hosts/x1c/disk.nix
      inputs.self.modules.nixos.default
      {
        networking.hostName = "x1c";
        system.stateVersion = "26.11";
      }
      inputs.home-manager.nixosModules.home-manager
      (
        { username, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hmbak";
          home-manager.users.${username} = {
            imports = [ inputs.self.modules.homeManager.default ];
            # Building `man home-configuration.nix` adds ~2s of eval and a
            # 2.4 MiB artifact to every switch, for a page also served at
            # https://nix-community.github.io/home-manager/options.xhtml
            manual.manpages.enable = false;
          };
        }
      )
    ];
  };
}
