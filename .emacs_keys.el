;;basics
;; enabling friendly C-c C-x C-z shortcuts when there is a selection
(cua-mode t)

;; NOTE: C-o handling also is re-mapped in dired mode (opened dir in frame
;; by default)
(global-set-key (kbd "C-o") 'find-file)

;;mouse

(xterm-mouse-mode 1)
;; Setting mouse key to go into desired coordinates(otherwise xref-find-definitions
;; would go to null/invalid place under cursor
(global-set-key [(C-down-mouse-1)]
  (lambda (event)
    (interactive "e")
    (let ((posn (elt event 1)))
      (with-selected-window (posn-window posn)
        (goto-char (posn-point posn))
        ))
    )
  )

(global-set-key [(mouse-4)] (lambda () (interactive) (scroll-down 8)) )
(global-set-key [(mouse-5)]  (lambda () (interactive) (scroll-up 8)) )
(global-set-key [(mouse-2)] 'mouse-yank-at-click) ;middle button paste

;; TODO: temporarily removing copy on mouse select
;copy on mouse select
;;(setq mouse-drag-copy-region t)

;; normal shell history using arrows
;; (progn(require 'comint))
;; (define-key comint-mode-map (kbd "<up>") 'comint-previous-input)
;; (define-key comint-mode-map (kbd "<down>") 'comint-next-input)

(global-set-key (kbd "C-M-w") 'whitespace-mode)

(global-set-key (kbd "C-M-_") 'comment-line) ;; C-M-/

;;calls make
(global-set-key (kbd "C-M-b") 'compile)

;; friendly enlarge window
(global-set-key (kbd "<f1>") 'magit-status)
(global-set-key (kbd "<f2>") 'eval-buffer)

;; NOTE: f3 and f4 by standard are usefull for macro define/execute
;; smart toggle-switch for <f4> ibuffer key
(add-hook 'ibuffer-mode-hook
          (lambda ()
            (define-key ibuffer-mode-map (kbd "<f4>") 'previous-buffer)))

;; NOTE: add '-L' to find to follow symlink references
(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (eshell-command
   (format "find -L %s -type f -regex '.*/.*\\.\\(c\\|cpp\\|hpp\\|h\\|pl\\)$\'| etags - &" dir-name)))
(global-set-key (kbd "<f5>") 'create-tags)

(global-set-key (kbd "<f6>") 'visit-tags-table)
(global-set-key (kbd "<f7>") '(lambda ()  (interactive) (ansi-term "/bin/zsh")))
;; and smart toggle-kill terminal for <f7> 
(add-hook 'term-mode-hook
          (lambda ()
            (define-key term-raw-map (kbd "<f7>") 'kill-this-buffer)))

(global-set-key (kbd "<f8>") 'list-bookmarks)
;; and smart toggle kill-bookmarks for <f8>
(add-hook 'bookmark-bmenu-mode-hook
          (lambda ()
            (define-key bookmark-bmenu-mode-map (kbd "<f8>") 'kill-this-buffer)))

;; TODO: f9 free

(defun xah-user-buffer-q ()
  "Return t if current buffer is a user buffer, else nil.
Typically, if buffer name starts with *, it's not considered a user buffer.
This function is used by buffer switching command and close buffer command, so that next buffer shown is a user buffer.
You can override this function to get your idea of â€œuser bufferâ€.
version 2016-06-18"
  (interactive)
  (if (string-equal "*" (substring (buffer-name) 0 1))
      ;"*" in name
      (cond
       ((string-equal "*Help*" (buffer-name)) nil)
       ((string-equal "*Completions*" (buffer-name)) nil)
       ((string-equal "*Semantic SymRef*" (buffer-name)) nil)
       ((string-equal "*Messages*" (buffer-name)) nil)
       (t t)
       )
    ;not "*" in name
    (cond
     ((string-equal "TAGS" (buffer-name)) nil) ;; ignoring
     ((string-equal "COPYING" (buffer-name)) nil) ;; ignoring
	 ((string-equal "magit" (substring (buffer-name) 0 5) ) nil) ;; ignore magit buffers
     (t t)
     )
    ))

(defun xah-next-user-buffer ()
  "Switch to the next user buffer.
“user buffer” is determined by `xah-user-buffer-q'.
URL `http://ergoemacs.org/emacs/elisp_next_prev_user_buffer.html'
Version 2016-06-19"
  (interactive)
  (next-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (not (xah-user-buffer-q))
          (progn (next-buffer)
                 (setq i (1+ i)))
        (progn (setq i 100))))))

(defun xah-previous-user-buffer ()
  "Switch to the previous user buffer.
“user buffer” is determined by `xah-user-buffer-q'.
URL `http://ergoemacs.org/emacs/elisp_next_prev_user_buffer.html'
Version 2016-06-19"
  (interactive)
  (previous-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (not (xah-user-buffer-q))
          (progn (previous-buffer)
                 (setq i (1+ i)))
                  (progn (setq i 100))))))

;;f10 used for menu in text mode - better not touch
(global-set-key (kbd "<f11>") 'xah-previous-user-buffer)
(global-set-key (kbd "<f12>") 'xah-next-user-buffer)

(global-set-key (kbd "C-l") 'goto-line)

;; isearch selection string wrappers
(defun search-selection-string (str is_forward)
  "Searches for string using isearch-forward/isearch-backward.
In order to use it for backward search, just pass nil as is_forward param"
  (interactive "s\nc")
  (deactivate-mark)
  (isearch-mode is_forward nil nil nil)
  (isearch-yank-string selection_string)
  )

(defun search-forward-wrapper ()
  "If some region is marked, put marked text in search area.
If not, then fallback to standard isearch-forward"
  (interactive)
  (if (region-active-p)
      (let ((selection_string
             (buffer-substring-no-properties (region-beginning) (region-end))))
        (search-selection-string selection_string t)
        )
    (isearch-forward) ; no marked selection - fallback to stanard search
    )
  )

(global-set-key (kbd "C-s") 'search-forward-wrapper)

(defun search-backward-wrapper ()
  "If some region is marked, put marked text in search area.
If not, then fallback to standard isearch-backward"
  (interactive)
  (if (region-active-p)
      (let ((selection_string
             (buffer-substring-no-properties (region-beginning) (region-end))))
        (search-selection-string selection_string nil)
        )
    (isearch-backward) ; no marked selection - fallback to stanard search
    )
  )

(global-set-key (kbd "C-r") 'search-backward-wrapper)

;; Smart wrapper for M-.
(defun wrap-object-code-search ()
  "Wraps searching for M-. in order to make it smarter:
- when we are on header line, go to header by ff-find-other-file
- when we are elsewhere, try to find object definitions via xref-find-definitions "
  (interactive)
  (let ((xref_find_mode nil))
    (save-excursion ;; save cursor position
      (beginning-of-line)
      (if (search-forward "#include " (line-end-position) t)
          (call-interactively 'ff-find-other-file)
        (setq xref_find_mode t) ;fallback to standard search M-. below
        )
      )
    ;; if we are here and search for include was not launched, then calling M-.
    ;; by xref-find-definitions
    (when xref_find_mode
      (xref-find-definitions (symbol-name(symbol-at-point))))
    )
  )

(global-set-key (kbd "M-.") 'wrap-object-code-search)
(global-set-key [(C-mouse-1)] 'wrap-object-code-search)

;; Run command in current directory - not used frequently now though
(defun in-directory (dir)
  "Runs execute-extended-command with default-directory set to the given
directory."
  (interactive "DIn directory: ")
  (let ((default-directory dir))
    (call-interactively 'execute-extended-command)))
(global-set-key (kbd "M-X") 'in-directory)

(defun copy-line (&optional arg)
  "Do a kill-line but copy rather than kill.  This function directly calls
    kill-line, so see documentation of kill-line for how to use it including prefix
    argument and relevant variables.  This function works by temporarily making the
    buffer read-only."
  (interactive "P")
  (let ((buffer-read-only t)
        (kill-read-only-ok t))
    (move-beginning-of-line nil)
    (kill-line arg)))
    ;; optional key binding
(global-set-key (kbd "C-c k") 'copy-line)
;; have to fix this mapping also in perl and C-mode (some comment style)

(defun last-edit ()
  "Go back to last add/delete edit"
  (interactive)
  (let* ((ubuf (cadr buffer-undo-list))
     (beg (car ubuf))
     (end (cdr ubuf)))
    (cond
     ((integerp beg) (goto-char beg))
     ((stringp beg) (goto-char (abs end))
      (message "DEL-> %s" (substring-no-properties beg)))
     (t (message "No add/delete edit occurred")))))
(global-set-key (kbd "M-e") 'last-edit)

;; go to minibuffer
(defun switch-to-minibuffer ()
  "Switch to minibuffer window."
  (interactive)
  (if (active-minibuffer-window)
      (select-window (active-minibuffer-window))
    (error "Minibuffer is not active")))

(defun qrc (replace-str)
   (interactive "sDo query-replace current word with: ")
   (forward-word)
   (let ((end (point)))
      (backward-word)
      (kill-ring-save (point) end)
      (query-replace (current-kill 0) replace-str) ))
(global-set-key (kbd "C-c r") 'qrc) ;; Replace word under cursor

(global-set-key "\C-co" 'switch-to-minibuffer) ;; Bind to `C-c o'
(global-set-key (kbd "C-c d") 'delete-trailing-whitespace) ;; delete single ws on beginning/end lines

(global-set-key (kbd "C-c s") 'isearch-forward-symbol-at-point)

;; Vi compatibility shortuts
;;set mark commands
(global-set-key (kbd "M-SPC") 'set-mark-command)
(global-set-key (kbd "C-x C-n") 'company-complete)
(global-set-key (kbd "C-c v") 'rectangle-mark-mode) ;; normally C-x <space>

(with-eval-after-load 'ibuffer
  (define-key ibuffer-mode-map (kbd "f") 'ibuffer-filter-by-name))

(with-eval-after-load 'dired
  ;; DIRED mode helpers
  ;; dired narrow mode - dynamic filtering of directories after '/'
  (define-key dired-mode-map (kbd "/") 'dired-narrow)
  ;; 'f' key maps to enter in this mode, can take it safely
  (define-key dired-mode-map (kbd "f") 'dired-narrow)

  ;; dired-subtree module insert and close
  (define-key dired-mode-map (kbd "i") 'dired-subtree-insert)
  (define-key dired-mode-map (kbd ";") 'dired-subtree-remove)

  ;; dired-ranger handy copy-paste-move operations
  (define-key dired-mode-map (kbd "W") 'dired-ranger-copy)
  (define-key dired-mode-map (kbd "X") 'dired-ranger-move)
  (define-key dired-mode-map (kbd "Y") 'dired-ranger-paste)

  (define-key dired-mode-map (kbd "<DEL>") 'dired-up-directory)
) ;; end of dired mode keys

;; use IVY for virtual buffers with C-c v and C-c V shortcuts
(setq ivy-use-virtual-buffers t)
(global-set-key (kbd "C-c i") 'ivy-push-view)
(global-set-key (kbd "C-c I") 'ivy-switch-view)

;; remapping mark word to mark entire word
(defun mark-whole-word (&optional arg allow-extend)
  "Like `mark-word', but selects whole words and skips over whitespace.
If you use a negative prefix arg then select words backward.
Otherwise select them forward.

If cursor starts in the middle of word then select that whole word.

If there is whitespace between the initial cursor position and the
first word (in the selection direction), it is skipped (not selected).

If the command is repeated or the mark is active, select the next NUM
words, where NUM is the numeric prefix argument.  (Negative NUM
selects backward.)"
  (interactive "P\np")
  (let ((num  (prefix-numeric-value arg)))
    (unless (eq last-command this-command)
      (if (natnump num)
          (skip-syntax-forward "\\s-")
        (skip-syntax-backward "\\s-")))
    (unless (or (eq last-command this-command)
                (if (natnump num)
                    (looking-at "\\b")
                  (looking-back "\\b")))
      (if (natnump num)
          (left-word)
        (right-word)))
    (mark-word arg allow-extend)))

;; Now M-@ works much better
(global-set-key [remap mark-word] 'mark-whole-word)

(global-set-key (kbd "C-c SPC") 'just-one-space)

(defun bjm/kill-this-buffer ()
  "Kill the current buffer."
  (interactive)
  (kill-buffer (current-buffer)))

;; kill current buffer without asking questions
(global-set-key (kbd "C-x k") 'bjm/kill-this-buffer)

;; transpose two windows with each other
(global-set-key (kbd "C-x t") 'window-swap-states)

;; M-s save-buffer helper
(global-set-key (kbd "M-s") 'save-buffer)

;; on some terminal 'End' is mapped as '<select>
(global-set-key (kbd "<select>") 'move-end-of-line)

;; evil-mode key fixes to do not enable - not
;; re-binding all standard keypresses because there is
;; simply too much of them C-z C-x C-v C-k C-e ....
;; Easier simply to disable it when not needed
(with-eval-after-load 'evil
  (evil-set-initial-state 'ibuffer-mode 'emacs)
  (evil-set-initial-state 'bookmark-bmenu-mode 'normal)
  (evil-set-initial-state 'dired-mode 'emacs)
  (evil-set-initial-state 'magit-mode 'emacs))
(setq evil-insert-state-map (make-sparse-keymap))
(define-key evil-insert-state-map (kbd "<escape>") 'evil-normal-state)

;; Adds smart integration with query-replace for re-builder
;; (Copying between re-builder and isearch/standard replace works
;; poorly)
(defun reb-query-replace (to-string)
  "Replace current RE from point with `query-replace-regexp'."
  (interactive
   (progn (barf-if-buffer-read-only)
          (list (query-replace-read-to (reb-target-binding reb-regexp)
                                       "Query replace"  t))))
  (with-current-buffer reb-target-buffer
    (query-replace-regexp (reb-target-binding reb-regexp) to-string)))

(with-eval-after-load 're-builder
  (setq reb-re-syntax 'string)          ; normally \\ are needed instead of \
  (define-key reb-mode-map (kbd "M-%") 'reb-query-replace))

(defun rj-insert-todo-comment ()
  "Simple function for generating TODO comment body (mapped to C-c t)"
  (interactive)
  (message "Insert todo called!")
  (call-interactively 'comment-dwim)
  (insert "TODO: "))

(global-set-key (kbd "C-c t") 'rj-insert-todo-comment)

;; Alt-Arrows navigation (NOTE: some shells interprets Alt-Arrow as Esc-Arrow
;; so it looks quite messy...)
(require 'windmove)
(global-set-key (kbd "<ESC> <down>") 'windmove-down)
(global-set-key (kbd "<ESC> <up>") 'windmove-up)
(global-set-key (kbd "<ESC> <left>") 'windmove-left)
(global-set-key (kbd "<ESC> <right>") 'windmove-right)

(global-set-key (kbd "M-<down>") 'windmove-down)
(global-set-key (kbd "M-<up>") 'windmove-up)
(global-set-key (kbd "M-<left>") 'windmove-left)
(global-set-key (kbd "M-<right>") 'windmove-right)

;; unbind alt-arrow sequences from terminal to allow window movement
;; also M-x is quite usefull in emacs even in terminal
(add-hook 'term-mode-hook
          (lambda()
            (define-key term-raw-map (kbd "M-x") 'nil)
            (define-key term-raw-map (kbd "ESC ESC") 'nil)))

(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

(global-set-key (kbd "C-c e") 'iedit-mode)
(global-set-key (kbd "C-c h") 'highlight-indentation-mode)
