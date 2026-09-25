;;; $DOOMDIR/packages.el -*- lexical-binding: t; -*-

(package! super-save)
(package! tmr)
(package! winpulse
  :recipe (:host github :repo "xenodium/winpulse"))
(package! sqlite-mode-extras
  :recipe (:host github :repo "xenodium/sqlite-mode-extras"))
(package! denote)
(package! org-draw)
(package! diredfl :disable t)
(package! shell-maker)
(package! acp)
(package! agent-shell)
(package! sops)
(package! phpstan)
(package! flymake-phpstan)
(package! minuet)
(package! transpose-frame)
(package! org-retroclock
  :recipe (:host github :repo "Jotham-LEC/org-retroclock")
  :pin "8ad26124db64b5d3df0f99d0e292a13fa866109b")
(package! persp-mode-tab-bar
  :recipe (:host github :repo "Jotham-LEC/persp-mode-tab-bar")
  :pin "84a926d5ef8f5dc082616433b5058fda3520bfef")
