;;; my-minuet.el -*- lexical-binding: t; -*-

(defvar my/minuet-api-key nil
  "OpenRouter key, cached after the first successful read of the sops secret.")

(defun my/minuet-api-key ()
  "Return the OpenRouter API key from the sops secret.
`minuet' calls this on every request, so the value is cached — but only
once it is non-empty, so a daemon that outlived a rebuild still recovers."
  (or my/minuet-api-key
      (when-let* ((f my/openrouter-key-file)
                  ((file-readable-p f))
                  (key (string-trim
                        (with-temp-buffer (insert-file-contents f) (buffer-string))))
                  ((not (string-empty-p key))))
        (setq my/minuet-api-key key))))

;; `corfu-map' is consulted ahead of `minuet-active-mode-map', so its M-n/M-p
;; would shadow minuet's whenever the popup is up — which is nearly always, at
;; `corfu-auto-delay' 0.06.  Hand those two keys over; corfu still cycles on
;; TAB/S-TAB, C-n/C-p and C-j/C-k.
(after! corfu
  (map! :map corfu-map
        "M-n" nil
        "M-p" nil))

(use-package! minuet
  :defer t
  :init
  ;; Opt-in only, so nothing reaches the API unasked. These autoloaded
  ;; bindings are what load minuet; in `:config' they could never fire.
  (map! "M-i" #'minuet-show-suggestion)

  (map! :leader
        :desc "Minuet auto-suggestion"       "t m" #'minuet-auto-suggestion-mode
        :desc "Minuet complete (minibuffer)" "c m" #'minuet-complete-with-minibuffer)
  :config
  (setq minuet-provider 'openai-compatible
        minuet-context-window 8000
        minuet-n-completions 1
        minuet-request-timeout 5
        minuet-auto-suggestion-debounce-delay 0.5
        minuet-auto-suggestion-throttle-delay 1.5
        minuet-add-single-line-entry nil)

  (plist-put minuet-openai-compatible-options
             :end-point "https://openrouter.ai/api/v1/chat/completions")
  (plist-put minuet-openai-compatible-options :api-key #'my/minuet-api-key)
  (plist-put minuet-openai-compatible-options :model "~deepseek/deepseek-v4-flash-latest")

  ;; This model reasons at high effort by default.  "none" is absent from its
  ;; advertised supported_efforts but does disable it, and `json-serialize'
  ;; rejects the bare symbol the upstream README suggests.
  (minuet-set-optional-options minuet-openai-compatible-options :reasoning '(:effort "none"))
  ;; 128 makes it ramble and adds a multi-second tail; 64 measured clean and fast.
  (minuet-set-optional-options minuet-openai-compatible-options :max_tokens 64)
  (minuet-set-optional-options minuet-openai-compatible-options :temperature 0.2)

  (map! :map minuet-active-mode-map
        "M-n"   #'minuet-next-suggestion
        "M-p"   #'minuet-previous-suggestion
        "M-A"   #'minuet-accept-suggestion
        "M-a"   #'minuet-accept-suggestion-line
        "M-w"   #'minuet-accept-suggestion-word
        "M-e"   #'minuet-dismiss-suggestion))
