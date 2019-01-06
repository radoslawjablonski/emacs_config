#! /usr/bin/emacs --script

(setq package-list '(ansible clojure-mode company-irony company-irony-c-headers elpy company f find-file-in-project flycheck-irony flycheck groovy-imports groovy-mode highlight-indentation irony-eldoc irony ivy jinja2-mode magit git-commit ghub let-alist magit-popup dash pcache pkg-info epl pyvenv s with-editor async yasnippet yaml-mode))

(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-refresh-contents)

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))
