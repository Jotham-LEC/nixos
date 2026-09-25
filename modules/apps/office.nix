{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      environment.unixODBCDrivers = [ pkgs.unixodbcDrivers.sqlite ];
    };

  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          hledger
          ledger
          libreoffice
          sqlite
          unixodbc
          ;
      };
    };
}
