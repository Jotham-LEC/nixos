{ inputs, ... }:
{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      agent-browser = llm-agents.agent-browser;

      # session/fork has returned a transcript-only session since v0.71.0: it is
      # never made live, so agent-shell-fork's first request to it (setting the
      # default mode, then every prompt) fails with "Session not found".  Drop
      # once https://github.com/agentclientprotocol/claude-agent-acp/pull/1117
      # lands in nixpkgs.
      claude-agent-acp-patched = pkgs.claude-agent-acp.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../../pkgs/patches/claude-agent-acp-activate-forked-sessions.patch
        ];
      });

      claude-agent-acp = pkgs.symlinkJoin {
        inherit (claude-agent-acp-patched) name meta;
        paths = [ claude-agent-acp-patched ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/claude-agent-acp \
            --set-default CLAUDE_CODE_EXECUTABLE ${lib.getExe config.programs.claude-code.package}
        '';
      };

      claude-notify = pkgs.writeShellApplication {
        name = "claude-notify";
        runtimeInputs = [
          pkgs.jq
          pkgs.libnotify
        ];
        text = builtins.readFile ./claude-notify.sh;
      };
      notifyHook = event: {
        hooks = [
          {
            type = "command";
            timeout = 5;
            command = "${lib.getExe claude-notify} ${event} 2>/dev/null || true";
          }
        ];
      };
    in
    {
      home.packages = [
        agent-browser
        claude-agent-acp
        llm-agents.eca
        pkgs.context7-mcp
        pkgs.opencode
      ];

      programs.claude-code = {
        enable = true;
        mcpServers = {
          agent-browser = {
            type = "stdio";
            command = lib.getExe agent-browser;
            args = [ "mcp" ];
          };
          context7 = {
            type = "stdio";
            command = lib.getExe pkgs.context7-mcp;
            args = [ ];
          };
          loops = {
            type = "http";
            url = "https://mcp.loops.so";
          };
        };

        settings = {
          theme = "auto";
          tui = "fullscreen";
          agentPushNotifEnabled = true;
          skipDangerousModePermissionPrompt = true;

          hooks = {
            Stop = [ (notifyHook "stop") ];
            Notification = [ (notifyHook "notification") ];
          };
        };
      };
    };
}
