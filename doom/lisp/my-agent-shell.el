;;; my-agent-shell.el -*- lexical-binding: t; -*-

(use-package! agent-shell
  :commands (agent-shell-anthropic-start-claude-code agent-shell-send-clipboard-image)
  :init
  (set-evil-initial-state! 'agent-shell-diff-mode 'emacs)

  (map! :leader
        (:prefix ("k" . "Agent Shell")
         :desc "Start Claude"   "c" #'agent-shell-anthropic-start-claude-code
         :desc "Start OpenCode" "o" #'agent-shell-opencode-start-agent
         :desc "Picker (raw)"   "p" #'agent-shell
         :desc "Restart agent"  "r" #'agent-shell-restart
         :desc "Paste image"    "i" #'agent-shell-send-clipboard-image))
  :config
  (setopt
   agent-shell-context-sources nil
   agent-shell-header-style 'text
   agent-shell-anthropic-default-session-mode-id "auto"))

(provide 'my-agent-shell)
