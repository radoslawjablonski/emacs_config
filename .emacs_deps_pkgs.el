(defvar custom/packages_rj
'(
  company
  irony
  irony-eldoc
  company-irony
  company-irony-c-headers
  yasnippet
  elpy
  magit
  flycheck-irony
  ansible
  jinja2-mode
  clojure-mode
  )
"Default packages")


(message "%s" "Refreshing package database...")
(package-refresh-contents)
(dolist (pkg custom/packages_rj)
  (package-install pkg))

