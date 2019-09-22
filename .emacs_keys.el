;;basics

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

(global-set-key [(C-mouse-1)] 'xref-find-definitions)
(global-set-key [(mouse-4)] (lambda () (interactive) (scroll-down 8)) )
(global-set-key [(mouse-5)]  (lambda () (interactive) (scroll-up 8)) )
(global-set-key [(mouse-2)] 'mouse-yank-at-click) ;middle button paste

;copy on mouse select
(setq mouse-drag-copy-region t)

;; normal shell history using arrows
(progn(require 'comint))
(define-key comint-mode-map (kbd "<up>") 'comint-previous-input)
(define-key comint-mode-map (kbd "<down>") 'comint-next-input)

;(global-set-key (kbd "M-<up>") 'backward-sentence)
;(global-set-key (kbd "M-<down>") 'forward-sentence)
;(global-set-key (kbd "ESC <up>") 'backward-sentence)
;(global-set-key (kbd "ESC <down>") 'forward-sentence)

;;select all redefined friendly way
;;(global-set-key (kbd "C-x C-a") 'mark-whole-buffer) ;removed because of conflict with gdb
(global-set-key (kbd "C-M-w") 'whitespace-mode)
;; friendly key for undo!
(global-set-key (kbd "C-u") 'universal-argument)
;; and setting up previously unset C-u (universal argument)
;; (global-set-key (kbd "C-;") 'universal-argument) ;; problem undar terminal :/

;; comment region similar to eclipse (normally it binds to UNDO, C-/ is problematic :( )
;; same as C-c C-c
(global-set-key (kbd "C-x /") 'comment-line)
(global-set-key (kbd "C-c /") 'comment-line)

;;calls make
(global-set-key (kbd "C-M-b") 'compile)

;; friendly enlarge window
(global-set-key (kbd "<f1>") 'evil-mode)
(global-set-key (kbd "<f2>") 'eval-buffer)
(global-set-key (kbd "<f3>") 'magit-status)
(global-set-key (kbd "<f4>") 'ff-find-other-file) ;;change header/source line in QtCreator

;; NOTE: add '-L' to find to follow symlink references
(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (eshell-command
   (format "find -L %s -type f -regex '.*/.*\\.\\(c\\|cpp\\|hpp\\|h\\|pl\\)$\'| etags - &" dir-name)))
(global-set-key (kbd "<f5>") 'create-tags)

(global-set-key (kbd "<f6>") 'visit-tags-table)
(global-set-key (kbd "<f7>") 'semantic-symref)
(global-set-key (kbd "<f8>") 'neotree-toggle)

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
       ((string-equal "*Ibuffer*" (buffer-name)) nil)
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
;(global-set-key (kbd "C-M-f") 'indent-region) ;;practically unused and standard regex search might suit better...

(defun in-directory (dir)
  "Runs execute-extended-command with default-directory set to the given
directory."
  (interactive "DIn directory: ")
  (let ((default-directory dir))
    (call-interactively 'execute-extended-command)))
(global-set-key (kbd "M-X") 'in-directory)

(defun transpose-buffers (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        )
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))
;; transpose two windows with each other
(global-set-key (kbd "C-x t") 'transpose-buffers)

(defun copy-line (&optional arg)
  "Do a kill-line but copy rather than kill.  This function directly calls
    kill-line, so see documentation of kill-line for how to use it including prefix
    argument and relevant variables.  This function works by temporarily making the
    buffer read-only."
      (interactive "P")
      (let ((buffer-read-only t)
            (kill-read-only-ok t))
        (kill-line arg)))
    ;; optional key binding
(global-set-key (kbd "C-c C-k") 'copy-line)

(defun mark-word-from-beginning ()
  "Mark current word to buffer no matter in which position of word we are"
  (interactive)
  (backward-word)
  (mark-word)
  (kill-ring-save (region-beginning) (region-end))
  (message "Marked %s" (car kill-ring))
  )
(global-set-key (kbd "M-#") 'mark-word-from-beginning)

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

(defun my-select-first-window ()
  (interactive)
  (select-window (frame-first-window)))

(global-set-key "\C-x<" 'my-select-first-window)
(defun my-select-last-window ()
  (interactive)
  (select-window (previous-window (frame-first-window))))

(global-set-key "\C-x>" 'my-select-last-window)

;; previous - next window configuration M-s M-p
(defun my-previous-window ()
  "Previous window"
  (interactive)
  (other-window -1))
(global-set-key (kbd "M-p") 'my-previous-window)

(global-set-key (kbd "M-s") 'other-window) ; cursor to other pane
(add-hook 'dired-mode-hook
          (lambda()
            (local-unset-key (kbd "M-s"))))

(defun copy-buffer-name ()
  (interactive)
  (kill-new (buffer-name))
  (message "Copied %s to the clipboard" (buffer-name))
)
(global-set-key (kbd "C-c b") 'copy-buffer-name) ; cursor to other pane

(add-hook 'cperl-mode-hook
          (lambda()
            (local-unset-key (kbd "C-c C-k"))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
(global-set-key (kbd "C-c m") 'maximize-window)
(global-set-key (kbd "C-c d") 'delete-trailing-whitespace) ;; delete single ws on beginning/end lines
(global-set-key (kbd "C-c f") 'flush-lines) ;; for deleting empty lines in selection, pass ^$

(global-set-key (kbd "C-c s") 'isearch-forward-symbol-at-point) ;Ctrl - S

;; Vi compatibility shortuts
;;set mark commands
(global-set-key (kbd "M-SPC") 'set-mark-command)
(global-set-key (kbd "C-x C-n") 'company-complete)
(global-set-key (kbd "C-v") 'rectangle-mark-mode) ;; normally C-x <space>

(with-eval-after-load 'dired
  ;; DIRED mode helpers
  ;; dired narrow mode - dynamic filtering of directories after '/'
  (define-key dired-mode-map (kbd "/") 'dired-narrow)

  ;; dired-subtree module insert and close
  (define-key dired-mode-map (kbd "i") 'dired-subtree-insert)
  (define-key dired-mode-map (kbd ";") 'dired-subtree-remove)

  ;; dired-ranger handy copy-paste-move operations
  (define-key dired-mode-map (kbd "W") 'dired-ranger-copy)
  (define-key dired-mode-map (kbd "X") 'dired-ranger-move)
  (define-key dired-mode-map (kbd "Y") 'dired-ranger-paste)
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
