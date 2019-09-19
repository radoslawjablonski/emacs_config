(load-theme 'tango-dark t)
(xterm-mouse-mode 1) ;mouse mode
(defalias 'list-buffers 'ibuffer) ; make ibuffer default


;; normal shell history using arrows
(progn(require 'comint))
(define-key comint-mode-map (kbd "<up>") 'comint-previous-input)
(define-key comint-mode-map (kbd "<down>") 'comint-next-input)


(setq mouse-drag-copy-region t) ;copy on mouse

(load-file "~/.emacs_keys.el")
