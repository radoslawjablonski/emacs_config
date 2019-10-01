 (package-initialize)
(add-to-list 'load-path "~/.emacs.d/site-lisp")

(add-to-list 'semantic-default-submodes 'global-semantic-idle-scheduler-mode)
(add-to-list 'semantic-default-submodes 'global-semantic-idle-summary-mode)
; don't know what it does exactly but at least annoyingly decorates headers, so disabling
;;(add-to-list 'semantic-default-submodes 'global-semantic-decoration-mode)
(add-to-list 'semantic-default-submodes 'global-semantic-show-tag-summaries-mode)

(load-file "~/.emacs_keys.el")
(load-file "~/.emacs_custom_func.el")
;; normally using whitespace where possible, NO TABS
(setq-default indent-tabs-mode nil)

(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
;; List of emacs-packages to install is handled in '.emacs_deps_pkgs.el'
;; just eval this bufffer to install all what is needed
;;
;; NOTE: below packages are handled by ansible :)
;; apt-get install libclang-dev clang cmake python3-pip cppcheck autotools-dev
;; sudo pip3 install jedi flake8 importmagic autopep8

;; Disabling because of irony :)
;(add-to-list 'semantic-default-submodes 'global-semantic-idle-completions-mode)
;; Annoying sticky func on top
;;(add-to-list 'semantic-default-submodes 'global-semantic-stickyfunc-mode)

;saving desktop states between quit sessions
;; (desktop-save-mode 1) ;;annoying on laptop every day use...

(show-paren-mode 1)

;disable menubar on top - can't remember when last time clicked on something
(menu-bar-mode -1)

;note - semanting interferes with popup company hints - cannot select
;semantic is quite annoying when used with company/irony "" - disabling
(semantic-mode 0)

;instead enabling yasnippet to help with command parameters
(yas-global-mode 1)

;line numbers mode enabled
;(global-linum-mode 1)

;; shows lines that are consisting only from whitespaces
(setq show-trailing-whitespace t)

(which-function-mode 1)
(setq show-paren-delay 0)
;always follow symlinks
(setq vc-follow-symlinks t)
;toolbar disable in gut
(tool-bar-mode -1)
(setq compilation-scroll-output t)

;; this allows us to get search word history when replacing
(setq enable-recursive-minibuffers t)

; do not delimit words by '_' when selecting
(add-hook 'c-mode-common-hook 'superword-mode)

;;disable auto-save
;;(setq make-backup-files nil) ; stop creating backup~ files
;;(setq auto-save-default nil) ; stop creating #autosave# files

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(defun c-linux-tab4-mode ()
  "Set kernel tab-len 4 mode for current buffer"
  (interactive)
  (setq-default indent-tabs-mode t)
  (setq-default tab-width 4)
  (setq c-default-style "linux" c-basic-offset 4)
  )

(defun c-linux-tab8-mode ()
  "Set kernel tab-len 8 mode for current buffer"
  (interactive)
  (setq-default indent-tabs-mode t)
  (setq-default tab-width 8)
  (setq c-default-style "linux" c-basic-offset 8)
  )

(defun c-linux-whitespace8-mode ()
  "Set kernel whitespace-len 8 mode for current buffer"
  (interactive)
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 8)
  (setq c-default-style "linux" c-basic-offset 8)
  )

;; Cedet hooks
(defun my-c-mode-cedet-hook ()
  (flycheck-mode)
  (flyspell-prog-mode)
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 4)
  (setq c-default-style "cc-mode" c-basic-offset 4)
  )

(add-hook 'c-mode-common-hook 'my-c-mode-cedet-hook)

;imenu - disabled
;(add-hook 'c-mode-common-hook 'imenu-add-menubar-index)

;; add completion at point
(global-set-key (kbd "C-@") 'company-complete) ;; for term
(global-set-key (kbd "C-SPC") 'company-complete) ;; for X

;; set default tab char's display width to 4 spaces
(setq-default tab-width 4) ; emacs 23.1, 24.2, default to 8

;; set current buffer's tab char's display width to 4 spaces
(setq tab-width 4)

;;column nubmer mode
(setq column-number-mode t)
;; remember cursor position, for emacs 25.1 or later
(save-place-mode 1)

(defalias 'list-buffers 'ibuffer) ; make ibuffer default

;auto revert/refresh buffer if changed on disk
(global-auto-revert-mode t)

(package-initialize) ;; You might already have this line
;(load "~/.emacs.d_plugins/clang-format.el")

(require 'doxymacs)
(doxymacs-font-lock)
(add-hook 'c-mode-common-hook 'doxymacs-mode)

;; C++ MODE
(defun my-c++-mode-hook ()
  (c-set-style "cc-mode")        ; use my-style defined above
  (auto-fill-mode)
  ;(c-toggle-auto-hungry-state 0) ; auto-newlines on {
  (local-set-key (kbd "C-/") 'comment-or-uncomment-region)
  (flyspell-prog-mode)
  (flycheck-mode)
  )

;; NOTE: for first run of irony mode call:
;; M-x irony-install-server
(add-hook 'c++-mode-hook 'my-c++-mode-hook)
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)

;; company mode for all buffers:)
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
(add-hook 'irony-mode-hook 'irony-eldoc) ;;eldoc for highlighting function signature below

(with-eval-after-load 'company
  (setq company-backends (delete 'company-semantic company-backends))
  (setq company-backends (delete 'company-clang company-backends))
  (with-eval-after-load 'c-mode
    (define-key c-mode-map [(tab)] 'company-complete))
  (with-eval-after-load 'c++-mode
    (define-key c++-mode-map [(tab)] 'company-complete))
  )

(require 'company-irony-c-headers)
(with-eval-after-load 'company
  '(add-to-list
    'company-backends '(company-irony-c-headers company-irony)))

;; irony-mode's buffers by irony-mode's function
(setq company-idle-delay 0.3)
(setq company-minimum-prefix-length 2) ;2 characters for starting completion

(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

(load "~/.emacs.d_plugins/fic-mode.el")
(require 'fic-mode) ;; TODO FIXME highlighting
(add-hook 'c-mode-hook 'turn-on-fic-mode)
(add-hook 'c++-mode-hook 'turn-on-fic-mode)
(add-hook 'emacs-lisp-mode-hook 'turn-on-fic-mode)
(add-hook 'shell-script-mode-hook 'turn-on-fic-mode)

;; NOTE - disabling CMAKE mode by default, not used anymore
;;(load "~/.emacs.d_plugins/cmake-mode.el")
;;(require 'cmake-mode)

;to do not confuse with movement
;(global-set-key (kbd "M-f") 'clang-format-region)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;open header after C-c o (if emacs is smart enough to find where it is)
(add-hook 'c-mode-common-hook
          (lambda()     (local-set-key  (kbd "C-c o") 'ff-find-other-file)))

;;shell config
(setq shell-file-name "zsh")

(elpy-enable)
(setq elpy-rpc-backend "jedi")
(setq elpy-rpc-python-command "python3")

;(load-theme 'challenger-deep t)

;;perl mode
(defalias 'perl-mode 'cperl-mode)
(setq cperl-electric-keywords t) ;; expands for keywords such as
;; foreach, while, etc...

(setq cperl-indent-level 4
	  cperl-close-paren-offset -4
	  cperl-continued-statement-offset 4
	  cperl-indent-parens-as-block t
	  cperl-tab-always-indent t)

;; ispell change dictionary to american-english
(setq ispell-dictionary "american")

;; Perl MODE hook
(defun my-cperl-mode-hook ()
  (flyspell-prog-mode)
  (flycheck-mode)
  )
(add-hook 'cperl-mode-hook 'my-cperl-mode-hook)

;; Commit message modes
(defun my-git-commit-mode-hook ()
  (flyspell-mode)
  )
(add-hook 'git-commit-mode-hook 'my-git-commit-mode-hook)

;; dired mode '!' support
(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")))

;; Auto-refresh dired on file change
(add-hook 'dired-mode-hook 'auto-revert-mode)
(setq auto-revert-verbose nil)

;; same auto refresh buf for ibuffer
(add-hook 'ibuffer-mode-hook
	  '(lambda ()
	     (ibuffer-auto-mode 1)))

;; Don't ask for confirmation when deleting buffer
(setq ibuffer-expert t)

;; Set auto-save bookmarks flag
(setq bookmark-save-flag 1)

; (load-theme 'adwaita t)
(load-theme 'wombat t)
;;(load-theme 'misterioso t)
;;(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
;; '(semantic-complete-inline-analyzer-idle-displayor-class (quote semantic-displayor-tooltip)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-comment-face ((t (:foreground "#62d196")))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-safe-themes
   (quote
    ("2fb337439962efc687d9f9f2bf7263e6de3e6b4b910154a02927c2a70acf496c" default)))
 '(gdb-many-windows t)
 '(menu-bar-mode nil)
 '(package-selected-packages
   (quote
    (dired-ranger dired-subtree dired-narrow dired-hacks-utils evil lalalilo groovy-imports groovy-mode clojure-mode yasnippet company jinja2-mode ansible forest-blue-theme challenger-deep-theme flycheck-irony eldoc-extension irony-eldoc yasnippet-snippets magit company-irony-c-headers company-irony irony elpy sr-speedbar flycheck)))
 '(python-shell-interpreter "python3")
 '(safe-local-variable-values
   (quote
    ((eval setq company-clang-arguments
           (quote
            ("--std=c99")))
     (eval setq company-clang-arguments
           (quote
            ("-std=c99")))
     (eval setq company-clang-arguments
           (quote
            ("-std=c++11"))))))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(put 'erase-buffer 'disabled nil)
