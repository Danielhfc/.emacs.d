;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Core settings
(setq
 ;;inhibit-startup-message t

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

;; Rebind undo
(global-set-key (kbd "C-z") 'undo)

;; Tabs to spaces
(setq-default indent-tabs-mode nil
 	            tab-width 2)

(keymap-set minibuffer-local-map "C-p" #'minibuffer-previous-completion)
(keymap-set minibuffer-local-map "C-n" #'minibuffer-next-completion)

;;Disable tooltips
(tooltip-mode -1)

;;Set up the visible bell
(setq visible-bell t)

;;Load black theme
(load-theme 'modus-vivendi)

;;Disable menu bar mode
(menu-bar-mode 0)

;;Disable tool bar mode
(tool-bar-mode 0)

;;Disable scroll bar mode
(scroll-bar-mode 0)

;;icomplete always show the candidates
;; (customize-set-variable 'icomplete-show-matches-on-no-input t)

;;Disable sounds
(setq ring-bell-function 'ignore)

;;Start in fullscreen mode
(add-hook 'window-setup-hook #'toggle-frame-fullscreen)

;; (savehist-mode 1)              ;; Save minibuffer history
(column-number-mode 1)         ;; Show column number on mode line
(global-visual-line-mode 1)    ;; Visually wrap long lines in all buffers

;; Display line numbers in programming modes
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Delete trailing whitespace before saving buffers
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Make vertical window separators look nicer in terminal Emacs
(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

;; Make Dired show folders and then files
(setq dired-listing-switches "-alh --group-directories-first")(setq dired-listing-switches "-alh --group-directories-first")

;; Set transparency of the window
(defun my/set-transparency (alpha)
  "Set current frame's background transparency to ALPHA (0-100)."
  (interactive "nTransparency percentage (0-100): ")
  (set-frame-parameter nil 'alpha-background alpha))

;; Start with 75% opacity on all frames
(add-to-list 'default-frame-alist '(alpha-background . 90))

;;Show possible completions for keybinds
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil ;; This is bundled with vertico, so we don't need to download it
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Cleans up the path when you type something like ~/foo//bar
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
         ("C-M-j" . consult-buffer)))

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

(global-set-key (kbd "C-c p F") #'consult-find)



;Delete the selected text upon text insertion
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(defun efs/first-available-font (fonts)
  "Return the first font in FONTS that is installed, or nil if none are."
  (seq-find (lambda (font) (find-font (font-spec :name font))) fonts))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (let ((font (efs/first-available-font '("Cantarell" "Ubuntu" "DejaVu Sans"))))
      (if font
          (set-face-attribute (car face) nil :font font :weight 'regular :height (cdr face))
        (set-face-attribute (car face) nil :weight 'regular :height (cdr face)))))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground 'unspecified :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode)
  :init
  (setq org-startup-indented t)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (efs/org-font-setup))

(add-hook 'find-file-hook 'my-org-mode-file-hook)
(defun my-org-mode-file-hook ()
  (when (string= (file-name-extension buffer-file-name) "org")
    (org-mode)))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

;; Make sure syntax highlighting is enabled globally
(global-font-lock-mode 1)

;; Load a built-in colorful theme (pick one)
(load-theme 'wombat t)
;; alternatives: tango-dark, leuven, tsdh-dark

(with-eval-after-load 'org
  ;; Ensure org headings are styled
  (setq org-fontify-done-headline t
        org-fontify-quote-and-verse-blocks t
        org-src-fontify-natively t)

  ;; Explicit heading colors (overrides theme if needed)
  (custom-set-faces
   '(org-level-1 ((t (:foreground "#ff79c6" :weight bold :height 1.2))))
   '(org-level-2 ((t (:foreground "#8be9fd" :weight bold :height 1.1))))
   '(org-level-3 ((t (:foreground "#50fa7b" :weight bold))))
   '(org-level-4 ((t (:foreground "#f1fa8c"))))
   '(org-level-5 ((t (:foreground "#bd93f9"))))
   '(org-level-6 ((t (:foreground "#ffb86c"))))))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))

(push '("conf-unix" . conf-unix) org-src-lang-modes)

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/emacs.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

;;Set up magit
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-dispatch)))

;; Configuration for ide-like when coding
(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/smart-dev-env-brz/workspace")
    (setq projectile-project-search-path '("~/smart-dev-env-brz/workspace")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; VS Code-like Ctrl-d behavior in Emacs
(use-package multiple-cursors
  :ensure t
  :bind (("C-d" . mc/mark-next-like-this)
         ;; Optional useful extras:
         ("C-S-d" . mc/mark-previous-like-this)
         ("C-c d" . delete-char)))  ; keep access to original C-d behavior

(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

(with-eval-after-load 'tramp
  (add-to-list 'tramp-methods
               '("docker"
                 (tramp-login-program "docker")
                 (tramp-login-args (("exec" "-it") ("%h") ("/bin/sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-c")))))

(use-package agent-shell
  :ensure t
  :bind ("C-c a s" . agent-shell))

;; Always start GitHub Copilot when calling `agent-shell' (set before the
;; package loads so the agent picker never appears)
(setq agent-shell-preferred-agent-config 'copilot)

(with-eval-after-load 'agent-shell
  (push
   (list (cons :command "powershell.exe")
         (cons :save
               (lambda (file-path)
                 (let* ((win-path (string-trim
                                   (shell-command-to-string
                                    (format "wslpath -w %s" (shell-quote-argument file-path)))))
                        (script (format "Add-Type -AssemblyName System.Windows.Forms; $i=[System.Windows.Forms.Clipboard]::GetImage(); if($i){$i.Save('%s',[System.Drawing.Imaging.ImageFormat]::Png)}else{exit 1}"
                                        win-path)))
                   (unless (and (zerop (call-process "powershell.exe" nil nil nil "-NoProfile" "-Command" script))
                                (file-exists-p file-path))
                     (error "No image in the Windows clipboard"))))))
   agent-shell-clipboard-image-handlers))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "pandoc")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

;; Always work inside the dev container (via TRAMP)
(require 'tramp)
(defvar my/dev-container "smart-dev-env-brz-shell")
(defvar my/dev-compose-dir "/home/daniel/smart-dev-env-brz")
(defvar my/dev-container-root (format "/docker:%s:/workspace/" my/dev-container))

(defun my/ensure-dev-container ()
  "Start the dev container if it is not running."
  (unless (equal "true" (string-trim
                         (shell-command-to-string
                          (format "docker inspect -f '{{.State.Running}}' %s 2>/dev/null"
                                  my/dev-container))))
    (let ((default-directory my/dev-compose-dir))
      (call-process "docker" nil nil nil "compose" "up" "-d"))))

(defun my/open-in-container ()
  (my/ensure-dev-container)
  (setq default-directory my/dev-container-root)
  (when (and (null command-line-args-left) (get-buffer "*scratch*"))
    (dired my/dev-container-root)))
(add-hook 'emacs-startup-hook #'my/open-in-container)
