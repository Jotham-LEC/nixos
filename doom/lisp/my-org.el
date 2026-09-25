;;; my-org.el -*- lexical-binding: t; -*-

(setq org-duration-format 'h:mm
      org-clock-report-include-clocking-task t
      org-download-link-format "[[file:%s]]\n"
      org-download-abbreviate-filename-function #'file-relative-name
      org-download-link-format-function #'org-download-link-format-function-default
      org-download-screenshot-method "grim -g \"$(slurp)\" %s"
      org-attach-preferred-new-method 'dir
      org-attach-store-link-p 'file
      org-attach-dir-relative t
      org-attach-archive-delete t)

(defun my/org-download-clipboard-guard (&rest _)
  (unless (string-match-p "image/" (shell-command-to-string "clip-paste --list-types 2>/dev/null"))
    (user-error "Clipboard has no image — copy one first")))
(advice-add 'org-download-clipboard :before #'my/org-download-clipboard-guard)

(after! ob-plantuml
  (setq org-plantuml-exec-mode 'plantuml
        org-plantuml-executable-path (executable-find "plantuml")))

(after! ox-pandoc
  (setq org-pandoc-options '((standalone . t))))

(defvar my-org-dir
  (expand-file-name "Projects/doom_emacs_roam_files/" (getenv "HOME")))

(setq org-directory my-org-dir
      org-attach-id-dir (concat my-org-dir ".attach/")
      org-hide-emphasis-markers nil
      org-auto-align-tags nil
      org-tags-column 0
      org-insert-heading-respect-content t
      org-pretty-entities t
      org-ellipsis "…"
      denote-directory my-org-dir)

;; `:hook' pulls in the autoload, so denote loads on the first Dired buffer
;; instead of needing an eager `require'.
(use-package! denote
  :hook (dired-mode . denote-dired-mode))

(defun my/org-auto-save ()
  "Silently save every modified Org file-buffer."
  (let ((inhibit-message t) (message-log-max nil))
    (save-some-buffers t (lambda () (and buffer-file-name (derived-mode-p 'org-mode))))))
(defvar my/org-auto-save-timer nil
  "Idle timer running `my/org-auto-save', or nil.")
(when (timerp my/org-auto-save-timer)
  (cancel-timer my/org-auto-save-timer))
(setq my/org-auto-save-timer (run-with-idle-timer 3 t #'my/org-auto-save))

(setq org-M-RET-may-split-line '((default . nil)))
;; Lives here rather than in config.el: `tmr-sound-file' reads
;; `my-org-dir', which is defined above.
(after! tmr
  (setq tmr-sound-file (expand-file-name "tmr-notification.wav" my-org-dir))
  (setq tmr-descriptions-list '("Pomodoro" "Break" "Meeting" "Focus" "Stretch"))
  (tmr-mode-line-mode 1)
  (after! embark
    (defvar-keymap embark-tmr-timer-map
      :doc "Embark keymap for TMR timers"
      :parent embark-general-map
      "c" #'tmr-cancel
      "C" #'tmr-clone
      "r" #'tmr-remove
      "R" #'tmr-reschedule
      "d" #'tmr-edit-description)
    (add-to-list 'embark-keymap-alist '(tmr-timer . embark-tmr-timer-map))))
(map! :leader
      (:prefix ("t" . "toggle/tmr")
               (:prefix ("t" . "tmr timers")
                :desc "Start timer" "t" #'tmr
                :desc "Timer with details" "T" #'tmr-with-details
                :desc "Tabulated view" "v" #'tmr-tabulated-view
                :desc "Cancel timer" "c" #'tmr-cancel
                :desc "Remove timer" "r" #'tmr-remove
                :desc "Clone timer" "C" #'tmr-clone
                :desc "Reschedule timer" "s" #'tmr-reschedule)))

;; Doom's `+word-wrap-mode' overrides `org-startup-truncated', folding wide
;; tables mid-row. Shrinking columns keeps prose wrapped and tables intact.
(setq org-startup-shrink-all-tables t)
;; `:after org' is load-bearing: `:lang org' binds `b t' as a fresh prefix-map
;; in its own `after! org', which would otherwise wipe this `w' out.
(map! :after org
      :map org-mode-map
      :localleader
      :desc "Shrink/expand column width" "b t w" #'org-table-toggle-column-width)

;; org-draw binds no keys; these are the author's suggested `C-c d' letters,
;; moved under the localleader (`D' is free in `:lang org'). Every command
;; here is autoloaded, so nothing loads until the first draw.
(map! :after org
      :map org-mode-map
      :localleader
      (:prefix ("D" . "draw")
       :desc "Draw / re-edit at point" "d" #'org-draw
       :desc "Edit figure at point"    "e" #'org-draw-edit
       :desc "Setup (receiver URL)"    "s" #'org-draw-setup
       :desc "Menu"                    "m" #'org-draw-menu))

(provide 'my-org)
