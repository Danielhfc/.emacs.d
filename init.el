(load-theme 'modus-vivendi)

(menu-bar-mode 0)

(tool-bar-mode 0)

(customize-set-variable -icomplete-show-matches-on-no-input t)

(icomplete-vertical-mode 1)

(setq ring-bell-function 'ignore)

(add-hook 'window-setup-hook #'toogle-frame-maximized)
