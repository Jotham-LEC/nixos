;;; my-mail.el -*- lexical-binding: t; -*-

(setq +org-msg-accent-color "#1155cc")
(after! org-msg
  (setf (nth 2 (assq 'b org-msg-enforce-css)) '((font-weight . "bold"))))

(after! mu4e
  (setq mu4e-change-filenames-when-moving t
        mu4e-search-skip-duplicates t
        mu4e-get-mail-command "mail-sync"
        mu4e-update-interval nil
        mu4e-sent-messages-behavior 'delete
        mu4e-context-policy 'pick-first
        mu4e-compose-context-policy 'ask-if-none
        mu4e-confirm-quit nil)

  (setq sendmail-program (executable-find "msmtp")
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail
        send-mail-function #'message-send-mail-with-sendmail)

  (setq message-fill-column nil)
  (add-hook 'mu4e-compose-mode-hook #'visual-line-mode)
  (add-hook 'org-msg-edit-mode-hook #'visual-line-mode)

  (add-to-list 'mu4e-headers-actions
               '("view in browser" . mu4e-action-view-in-browser) t)

  (defun +my/mu4e-view-in-browser ()
    "Open the message at point as HTML in the external browser."
    (interactive)
    (mu4e-action-view-in-browser (mu4e-message-at-point)))

  (map! :map (mu4e-headers-mode-map mu4e-view-mode-map)
        :localleader
        :desc "View in browser" "b" #'+my/mu4e-view-in-browser)

  (defadvice! +my/mu4e-from-follows-context-a (fn &rest args)
    "Don't let a parent message's recipients override the context's From."
    :around #'message-use-alternative-email-as-from
    (unless (bound-and-true-p mu4e-compose-type)
      (apply fn args)))

  (map! :map mu4e-compose-mode-map
        :localleader
        :desc "switch context" "c" #'mu4e-compose-context-switch)

  (defun +my/org-msg-context-switch ()
    "Switch the mu4e context of the current HTML draft."
    (interactive)
    (let ((old-context (mu4e-context-current))
          (old-signature org-msg-signature))
      (unless (eq old-context (mu4e-context-switch))
        (save-excursion
          (message-replace-header "From" (or (message-make-from) ""))
          (goto-char (point-min))
          (when (and old-signature (search-forward old-signature nil t))
            (replace-match (or org-msg-signature "") t t))))))

  (after! org-msg
    (map! :map org-msg-edit-mode-map
          "C-c ;" #'+my/org-msg-context-switch
          :localleader
          :desc "switch context" "c" #'+my/org-msg-context-switch))

  (setf (alist-get 'refile mu4e-marks)
        (list :char '("r" . "▶")
              :prompt "refile"
              :dyn-target (lambda (_target msg) (mu4e-get-refile-folder msg))
              :action (lambda (docid msg target)
                        (mu4e--server-move docid (mu4e--mark-check-target target) "+S-N"))))

  (setf (alist-get 'trash mu4e-marks)
        (list :char '("d" . "▼")
              :prompt "dtrash"
              :dyn-target (lambda (_target msg) (mu4e-get-trash-folder msg))
              :action (lambda (docid msg target)
                        (mu4e--server-move docid (mu4e--mark-check-target target)
                                           (if mu4e-trash-without-flag "+S-N" "+T+S-N")))))

  (defun +my/org-msg-signature (signature)
    (concat "\n\n#+begin_signature\n"
            (string-join (split-string signature "\n") "\\\\\n")
            "\n#+end_signature"))

  (defun +my/mu4e-context (account)
    "A mu4e context for ACCOUNT, a plist from `my/mail-accounts'."
    (let* ((maildir (format "/%s/" (plist-get account :maildir)))
           (address (plist-get account :address))
           (signature (plist-get account :signature)))
      (make-mu4e-context
       :name (plist-get account :name)
       :match-func
       (lambda (msg)
         (when msg
           (string-prefix-p maildir (mu4e-message-field msg :maildir))))
       :vars
       `((user-mail-address        . ,address)
         (user-full-name           . ,my/full-name)
         (+mu4e-personal-addresses . ,(cons address (plist-get account :aliases)))
         (message-signature        . ,signature)
         (org-msg-signature        . ,(+my/org-msg-signature signature))
         (mu4e-sent-folder         . ,(concat maildir "[Gmail]/Sent Mail"))
         (mu4e-drafts-folder       . ,(concat maildir "[Gmail]/Drafts"))
         (mu4e-trash-folder        . ,(concat maildir "[Gmail]/Trash"))
         (mu4e-refile-folder       . ,(concat maildir "[Gmail]/All Mail"))))))

  (defun +my/mu4e-inbox (account)
    (format "/%s/Inbox" (plist-get account :maildir)))

  (setq mu4e-contexts (mapcar #'+my/mu4e-context my/mail-accounts))

  (setq mu4e-maildir-shortcuts
        (mapcar (lambda (account)
                  (list :maildir (+my/mu4e-inbox account) :key (plist-get account :key)))
                my/mail-accounts))

  (setq mu4e-bookmarks
        `((:name "All inboxes"   :query ,(mapconcat (lambda (account)
                                                  (concat "maildir:" (+my/mu4e-inbox account)))
                                                my/mail-accounts " or ")
           :key ?i)
          (:name "Unread"        :query "flag:unread and not flag:trashed" :key ?u)
          (:name "Today"         :query "date:today..now"                  :key ?t)
          (:name "Flagged"       :query "flag:flagged"                     :key ?f))))

(provide 'my-mail)
