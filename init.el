;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Core settings
(setq ;; Yes, this is Emacs
      inhibit-startup-message t

      ;; Instruct auto-save-mode to save to the current file, not a backup file
      auto-save-default nil

      ;; No backup files, please
      make-backup-files nil

      ;; Make it easy to cycle through previous items in the mark ring
      set-mark-command-repeat-pop t

      ;; Don't warn on large files
      large-file-warning-threshold nil

      ;; Don't warn on advice
      ad-redefinition-action 'accept

      ;; Revert Dired and other buffers
      global-auto-revert-non-file-buffers t

      ;; Silence compiler warnings as they can be pretty disruptive
      native-comp-async-report-warnings-errors nil)

;; Tabs to spaces
(setq-default indent-tabs-mode nil
	      tab-width 2)

(setopt tab-always-indent 'complete
        read-buffer-completion-ignore-case t
        read-file-name-completion-ignore-case t

        ;; This *may* need to be set to 'always just so that you don't
        ;; miss other possible good completions that match the input
        ;; string.
        completion-auto-help t

        ;; Include more information with completion listings
        completions-detailed t

        ;; Move focus to the completions window after hitting tab
        ;; twice.
        completion-auto-select 'second-tab

        ;; If there are 3 or less completion candidates, don't pop up
        ;; a window, just cycle through them.
        completion-cycle-threshold 3

        ;; Cycle through completion options vertically, not
        ;; horizontally.
        completions-format 'vertical

        ;; Sort recently used completions first.
        completions-sort 'historical

        ;; Only show up to 10 lines in the completions window.
        completions-max-height 10

        ;; Don't show the unneeded help string at the top of the
        ;; completions buffer.
        completion-show-help nil

        ;; Add more `completion-styles' to improve candidate selection.
        completion-styles '(basic partial-completion substring initials))

(keymap-set minibuffer-local-map "C-p" #'minibuffer-previous-completion)
(keymap-set minibuffer-local-map "C-n" #'minibuffer-next-completion)

(use-package emacs-solo-rainbow-delimiters
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/rainbow-delimiters ()
    "Apply simple rainbow coloring to parentheses, brackets, and braces in the current buffer.
Opening and closing delimiters will have matching colors."
    (interactive)
    (let ((colors '(font-lock-keyword-face
                    font-lock-type-face
                    font-lock-function-name-face
                    font-lock-variable-name-face
                    font-lock-constant-face
                    font-lock-builtin-face
                    font-lock-string-face
                    )))
      (font-lock-add-keywords
       nil
       `((,(rx (or "(" ")" "[" "]" "{" "}"))
          (0 (let* ((char (char-after (match-beginning 0)))
                    (depth (save-excursion
                             ;; Move to the correct position based on opening/closing delimiter
                             (if (member char '(?\) ?\] ?\}))
                                 (progn
                                   (backward-char) ;; Move to the opening delimiter
                                   (car (syntax-ppss)))
                               (car (syntax-ppss)))))
                    (face (nth (mod depth ,(length colors)) ',colors)))
               (list 'face face)))))))
    (font-lock-flush)
    (font-lock-ensure))

  (add-hook 'prog-mode-hook #'emacs-solo/rainbow-delimiters))

;Delete the selected text upon text insertion
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(setq inhibit-startup-message t)
(tooltip-mode -1)           ; Disable tooltips

;; Set up the visible bell
(setq visible-bell t)

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

(savehist-mode 1)              ;; Save minibuffer history
(column-number-mode 1)         ;; Show column number on mode line
(global-visual-line-mode 1)    ;; Visually wrap long lines in all buffers

;; Display line numbers in programming modes
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Delete trailing whitespace before saving buffers
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Make vertical window separators look nicer in terminal Emacs
(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

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
(custom-set-variables
 '(package-selected-packages '(orderless marginalia)))

;;Set up magit
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-dispatch)))
