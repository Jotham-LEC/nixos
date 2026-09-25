{
  flake.modules.nixos.default =
    { pkgs, ... }:
    let
      firewall-status = pkgs.writeShellApplication {
        name = "firewall-status";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs)
            gawk
            gnugrep
            iptables
            coreutils
            docker
            systemd
            ;
        };
        text = builtins.readFile ./firewall-status.sh;
      };
    in
    {
      networking.firewall.logRefusedConnections = true;

      environment.systemPackages = [ firewall-status ];
    };
}
