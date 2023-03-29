(require 'package)

;; Adds the Melpa archive to the list of available repositories
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("elpa" . "https://elpa.gnu.org/packages/") t)

;; Initializes the package infrastructure
(package-initialize)

;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))
;; myPackages contains a list of package names
(defvar myPackages
  '(better-defaults                 ;; Set up some better Emacs defaults
    material-theme                  ;; Theme
    elpy                            ;; python ide like support
    flycheck                        ;; syntax check on the fly
    py-autopep8                     ;; run autopep8 on save
    blacken                         ;; black formatting on save
    magit                           ;; git integration
    evil                            ;; install vim emulation
    evil-better-visual-line
    evil-cleverparens
    evil-collection
    evil-numbers
    evil-org
    evil-surround
    evil-tree-edit
    tree-edit
    tree-sitter
    tree-sitter-ess-r
    tree-sitter-indent
    tree-sitter-ispell
    tree-sitter-langs
    material-theme
    better-defaults
    evil-args
    command-log-mode
    ivy
    counsel
    swiper
    ))

;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)


(add-to-list 'custom-theme-load-path' "~/.emacs.d/themes/")
(setq inhibit-startup-message t)
;; (load-theme 'vs-dark)
(load-theme 'material t)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-fringe-mode 10)
(global-linum-mode t)
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

(elpy-enable)

;; Enable Flycheck
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))
;; Enable autopep8
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
(require 'command-log-mode)

;; (defun linum-format-func (line)
;;  (let ((w (length (number-to-string (count-lines (point-min) (point-max))))))
;;     (propertize (format (format "%%4d \u2502 " w) line) 'face 'linum)))
;; (setq linum-format 'linum-format-func)
(setq linum-format "%4d \u2502 ")
(setq evil-want-keybinding nil)
(require 'evil)
(evil-mode 1)
(if (window-system)
    (progn
      (set-frame-height (selected-frame) 60)
      (set-frame-width (selected-frame) 150)))
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(tree-sitter-ispell tree-sitter-indent tree-sitter-ess-r py-autopep8 material-theme magit flycheck evil-tree-edit evil-surround evil-org evil-numbers evil-collection evil-cleverparens evil-better-visual-line evil-args elpy command-log-mode blacken better-defaults)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(ivy-mode 1)
