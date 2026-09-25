;;; my-ui.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family my/font-mono :size my/font-size)
      doom-variable-pitch-font (font-spec :family my/font-mono :size my/font-size))
(setq display-line-numbers-type 'visual)
(setq doom-theme 'doom-gruvbox)

(custom-set-faces!
  '(font-lock-comment-face     :foreground "#928374" :slant italic)
  '(font-lock-doc-face         :foreground "#7c6f64" :slant normal)
  '(font-lock-doc-markup-face  :foreground "#9a7123" :slant normal))
(when (fboundp 'set-fontset-font)
  (set-fontset-font t 'emoji my/font-emoji nil 'prepend))

(setq truncate-string-ellipsis "...")
(setq doom-modeline-buffer-encoding nil
      doom-modeline-percent-position nil
      doom-modeline-total-line-number nil
      doom-modeline-position-column-line-format nil
      doom-modeline-position-column-format nil
      doom-modeline-position-line-format nil
      doom-modeline-enable-buffer-position nil)
(size-indication-mode -1)
(winpulse-mode +1)
(provide 'my-ui)
