;;Set up the package manager
(require 'package)
(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;;Set up use-package
(when (< emacs-major-version 29)
  (unless (package-installed-p 'use-package)
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install 'use-package)))

;;Do not show warnings when installing packages
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

;Delete the selected text upon text insertion
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

;;Load black theme
(load-theme 'modus-vivendi)

;;Disable menu bar mode
(menu-bar-mode 0)

;;Disable tool bar mode
(tool-bar-mode 0)

;;Disable scroll bar mode
(scroll-bar-mode 0)

;;Enable completions in the minibuffer
(icomplete-vertical-mode 1)

;;icomplete always show the candidates
(customize-set-variable 'icomplete-show-matches-on-no-input t)

;;Disable sounds
(setq ring-bell-function 'ignore)

;;Start in fullscreen mode
(add-hook 'window-setup-hook #'toggle-frame-maximized)

;;Hotkeys for org-mode
 (global-set-key (kbd "C-c l") #'org-store-link)
     (global-set-key (kbd "C-c a") #'org-agenda)
     (global-set-key (kbd "C-c c") #'org-capture)

;;Set up magit
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-dispatch)))

;;Show commands description
(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

;;Show commands even if the order of the words are wrong
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides nil))

;;Show last used command
(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode))
