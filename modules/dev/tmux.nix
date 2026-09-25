{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        baseIndex = 1;
        plugins = [
          pkgs.tmuxPlugins.cpu
          pkgs.tmuxPlugins.resurrect
          {
            plugin = pkgs.tmuxPlugins.gruvbox;
            extraConfig = "set -g @tmux-gruvbox 'dark'";
          }
        ];
        extraConfig = ''
          set-option -g renumber-windows on
          setw -g pane-base-index 1
          set -g default-terminal "tmux-256color"
          set -as terminal-features ",foot:RGB"
        '';
      };
    };
}
