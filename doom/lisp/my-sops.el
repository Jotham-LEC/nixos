;;; my-sops.el --- -*- lexical-binding: t; -*-

(defconst my/sops-file-regex
  "\\(?:/secrets/[^/]+\\|\\.sops\\)\\.\\(?:ya?ml\\|json\\|env\\|ini\\)\\'")

(after! undo-fu-session
  (add-to-list 'undo-fu-session-incompatible-files my/sops-file-regex))

(use-package! sops
  :init
  (global-sops-mode 1)
  :config
  (setq sops-prefilter-regex my/sops-file-regex)
  (add-hook 'sops-mode-hook
            (lambda ()
              (when (bound-and-true-p undo-fu-session-mode)
                (undo-fu-session-mode -1))
              (setq-local create-lockfiles nil))))

(provide 'my-sops)
