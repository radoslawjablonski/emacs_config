;; NOTE: C-o handling also is re-mapped in dired mode (opened dir in frame
;; by default)
(global-set-key (kbd "C-o") 'find-file)

;; NOTE: f3 and f4 by standard are usefull for macro define/execute
;; smart toggle-switch for <f4> ibuffer key
(add-hook 'ibuffer-mode-hook
          (lambda ()
            (define-key ibuffer-mode-map (kbd "<f4>") 'previous-buffer)))
