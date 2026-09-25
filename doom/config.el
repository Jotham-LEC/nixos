;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(load! "lisp/my-nix-paths" nil t)
(setq user-full-name my/full-name
      user-mail-address my/mail-address)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(after! savehist
  (setq history-length 200
        history-delete-duplicates t
        savehist-autosave-interval 300
        savehist-additional-variables
        (remove 'kill-ring savehist-additional-variables)))

(setq projectile-project-search-path (list (expand-file-name "Projects/" (getenv "HOME"))))
(setq dired-kill-when-opening-new-dired-buffer t
      dired-mouse-drag-files t)

(defun my/dirvish-hide-details-everywhere ()
  "Force `dirvish-hide-details' so plain dired hides details too."
  (setq dirvish-hide-details t))
(after! dirvish (my/dirvish-hide-details-everywhere))

(add-hook 'doom-after-reload-hook #'my/dirvish-hide-details-everywhere)
(setq redisplay-skip-fontification-on-input t
      fast-but-imprecise-scrolling t
      scroll-conservatively 101
      scroll-margin 5
      maximum-scroll-margin 0.25
      delete-by-moving-to-trash t)

(setq gcmh-high-cons-threshold (* 128 1024 1024))

(use-package! super-save
  :hook (doom-first-file . super-save-mode)
  :config
  (setq super-save-auto-save-when-idle nil
        super-save-silent t
        super-save-all-buffers nil
        super-save-delete-trailing-whitespace nil))

(setq web-mode-enable-current-element-highlight t
      web-mode-enable-current-column-highlight nil
      web-mode-enable-element-tag-fontification t
      web-mode-enable-element-content-fontification t)

(after! lsp-tailwindcss
  (setq lsp-tailwindcss-server-path (executable-find "tailwindcss-language-server"))
  (lsp-register-custom-settings
   ;; Only "blade" is worth mapping: `lsp-tailwindcss-major-modes' has no
   ;; php-mode, so the client never attaches in a plain .php buffer and a
   ;; "php" entry here would never be consulted.
   `(("tailwindCSS.includeLanguages" ,(ht ("blade" "html"))))))

(after! phpstan
  ;; Matches the --memory-limit the project's composer scripts pass; PHPStan
  ;; dies mid-analysis on the Laravel app at 1G.
  (setq phpstan-memory-limit "2G"))

;; `:checkers syntax +flymake' never loads flycheck, so phpstan comes from
;; flymake-phpstan, alongside lsp-mode's diagnostics.
(add-hook 'php-mode-hook #'flymake-phpstan-turn-on)
(add-hook 'php-ts-mode-hook #'flymake-phpstan-turn-on)

(after! phpunit
  (setq phpunit-default-program
        (lambda ()
          (or (when-let* ((root (locate-dominating-file default-directory "vendor/bin/pest")))
                (expand-file-name "vendor/bin/pest" root))
              (when-let* ((root (locate-dominating-file default-directory "vendor/bin/phpunit")))
                (expand-file-name "vendor/bin/phpunit" root))
              "phpunit"))))

(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '("\\.blade\\.php$" . "blade"))
  (dolist (re '("[/\\\\]vendor\\'"
                "[/\\\\]storage\\'"
                "[/\\\\]bootstrap[/\\\\]cache\\'"
                "[/\\\\]public[/\\\\]build\\'"
                "[/\\\\]tmp\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re))
  ;; Even with those excluded, the bigger Laravel apps here present ~20k
  ;; watchable files, so the default 1000 only ever produces a prompt to
  ;; dismiss.
  (setq lsp-file-watch-threshold 30000)
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "laravel-lsp")
    :activation-fn (lambda (file-name _mode)
                     (and (locate-dominating-file file-name "artisan")
                          (or (string-match-p "\\.blade\\.php\\'" file-name)
                              (derived-mode-p 'php-mode 'php-ts-mode))))
    ;; "auto" picks Sail whenever vendor/bin/sail exists, even with Sail down,
    ;; leaving the index empty; PHP comes from the project devshell instead.
    :initialization-options (lambda () (ht ("phpEnvironment" "local")))
    :add-on? t
    :priority -1
    :server-id 'laravel-lsp)))

(after! lsp-php
  (setq lsp-intelephense-files-exclude
        (vconcat lsp-intelephense-files-exclude ["**/.direnv/**"]))
  (when-let* ((f my/intelephense-key-file)
              ((file-readable-p f)))
    (setq lsp-intelephense-licence-key
          (string-trim (with-temp-buffer (insert-file-contents f) (buffer-string))))))

(after! apheleia
  (setf (alist-get 'pint apheleia-formatters)
        '((let ((root (locate-dominating-file default-directory "vendor/bin/pint")))
            (if root (expand-file-name "vendor/bin/pint" root) "pint"))
          "--quiet" inplace)
        (alist-get 'php-mode apheleia-mode-alist) 'pint
        (alist-get 'php-ts-mode apheleia-mode-alist) 'pint
        (alist-get 'blade-formatter apheleia-formatters)
        '("blade-formatter" "--stdin" "--sort-tailwindcss-classes")
        (alist-get "\\.blade\\.php\\'" apheleia-mode-alist nil nil #'equal)
        'blade-formatter))

(after! lsp-ui
  (setq lsp-ui-sideline-enable nil))

(after! corfu
  (setq global-corfu-modes
        '((not erc-mode circe-mode help-mode gud-mode vterm-mode org-mode) t)))

(after! corfu-auto
  (setq corfu-auto-delay 0.06
        corfu-auto-prefix 1))

(add-hook! 'text-mode-hook
  (defun +corfu-relax-auto-in-prose-h ()
    (setq-local corfu-auto-delay 0.24
                corfu-auto-prefix 2)))

(defun my/open-in-file-manager ()
  (interactive)
  (let ((dir (if (derived-mode-p 'dired-mode)
                 (dired-current-directory)
               default-directory)))
    (start-process "file-manager" nil "xdg-open" dir)))

(map! :after dired
      :map dired-mode-map
      :localleader
      :desc "Create empty file"    "c" #'dired-create-empty-file
      :desc "Open in file manager" "o" #'my/open-in-file-manager)

(map! :after vterm
      :map vterm-mode-map
      "C-c <escape>" #'vterm-send-escape)

(defvar my/leader-window-map
  (let ((map (make-sparse-keymap))
        (parent (lookup-key doom-leader-map "w")))
    (set-keymap-parent map (if (symbolp parent) (symbol-function parent) parent))
    map)
  "What `SPC w' runs: whatever Doom already bound there, plus frame layout.
Doom binds `SPC w' to `evil-window-map' itself -- the keymap `C-w' uses --
so binding through a leader prefix would also take `C-w T' off
`tab-window-detach' and `C-w C-t' off `evil-window-top-left'.  A child map
shadows only the keys below and leaves `C-w' alone.")

(map! :map my/leader-window-map
      :desc "Transpose frame"            "T"     #'transpose-frame
      :desc "Rotate frame clockwise"     "C-t"   #'rotate-frame-clockwise
      :desc "Rotate frame anticlockwise" "C-S-t" #'rotate-frame-anticlockwise)

(map! :leader :desc "window" "w" my/leader-window-map)


(use-package! sqlite-mode-extras
  :hook (sqlite-mode . sqlite-extras-minor-mode)
  :init
  (when (modulep! :editor evil)
    (add-hook 'sqlite-extras-minor-mode-hook #'evil-normalize-keymaps))
  :config
  (map! :map sqlite-extras-minor-mode-map
        :n "<tab>"     #'sqlite-mode-extras-tab-dwim
        :n "<backtab>" #'sqlite-mode-extras-backtab-dwim
        :n "RET"       #'sqlite-mode-extras-ret-dwim
        :n "gr"        #'sqlite-mode-extras-refresh
        :n "+"         #'sqlite-mode-extras-add-row
        :n "D"         #'sqlite-mode-extras-delete-row-dwim
        :n "C"         #'sqlite-mode-extras-compose-and-execute
        :n "E"         #'sqlite-mode-extras-execute
        :n "S"         #'sqlite-mode-extras-execute-and-display-select-query))

(setq dape-adapter-dir my/dape-adapter-dir)

;; Redefines the one `:lang php' ships, whose :files is
;; (and "artisan" "server.php"). Laravel dropped server.php in 11, so
;; upstream's never fires on anything here.
(def-project-mode! +php-laravel-mode
  :modes '(php-mode php-ts-mode yaml-mode yaml-ts-mode web-mode nxml-mode js-mode js-ts-mode scss-mode)
  :files ("artisan"))

(use-package! persp-mode-tab-bar
  :hook (persp-mode . persp-mode-tab-bar-mode)
  ;; The tab bar names the workspace permanently, so the modeline needn't.
  :init (setq doom-modeline-workspace-name nil))

;; Doom's `SPC n c/C/o' already clock in, cancel and jump; add only the picker
;; for off-screen tasks and a jump to a past clock.
(map! :leader
      (:prefix ("n" . "notes")
       :desc "Clock in (recent)"      "i" (cmd! (org-clock-in (or current-prefix-arg '(4))))
       :desc "Goto clock (select)"    "O" (cmd! (org-clock-goto 'select))
       :desc "Retro clock (recent)"   "p" #'org-retroclock-recent))
(map! :after org
      :map org-mode-map
      :localleader
      :desc "Retro clock (log past)" "c p" #'org-retroclock)

(load! "lisp/my-ui")
(load! "lisp/my-agent-shell")
(load! "lisp/my-minuet")
(load! "lisp/my-sops")
(load! "lisp/my-org")
(load! "lisp/my-mail")
