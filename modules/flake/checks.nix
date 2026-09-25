{ inputs, ... }:
{
  perSystem.checks.x1c = inputs.self.nixosConfigurations.x1c.config.system.build.toplevel;
}
