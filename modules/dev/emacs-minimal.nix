{
  flake.modules.homeManager.default =
    { lib, pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellScriptBin "emacs-minimal" ''
          exec ${lib.getExe pkgs.emacs-pgtk} --init-directory="$HOME/.minimal-emacs.d" "$@"
        '')
      ];
    };
}
