{pkgs, ...}:
let
  sources = import ./../../nix/sources.nix;

  in with { overlay = _: pkgs:
    { niv = (import sources.niv {}).niv;
    };
  };

let
   nixpkgs = sources."nixpkgs";

   pkgs = import nixpkgs {
     overlays = [
      #(import sources.emacs-overlay)
	  (self: super:
	  {
	    # https://logs.nix.samueldr.com/nixos-emacs/2020-02-07
	    inherit ((import (builtins.fetchTarball {
		url = sources.emacs-overlay.url;
	    })) self super) emacsGit-nox emacsUnstable-nox emacsUnstable emacsWithPackagesFromUsePackage;
	  })
    ]; config = {};
  };
  saneEmacsEl = builtins.fetchurl "https://sanemacs.com/sanemacs.el";
  myEmacsConfig = pkgs.writeText "default.el" ''
;; -*- lexical-binding: t; -*-

;; https://sanemacs.com/ - A minimal Emacs config that does just enough and nothing more.
(load "./sanemacs.el" nil t)

;; https://github.com/raxod502/straight.el - 🍀 Next-generation, purely functional package manager for the Emacs hacker.
;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Load the straight.el version of use-package
(defvar straight-use-package-by-default)
(straight-use-package 'use-package)
;; Tell straight to use use-package by default
(setq straight-use-package-by-default t)

      ;; Disable startup message.
      (setq inhibit-startup-screen t
	    ;; https://github.com/emacs-dashboard/emacs-dashboard#emacs-daemon
	    initial-buffer-choice (lambda () (get-buffer "*Deft*"))
            ;; initial-buffer-choice 'ignore
            inhibit-startup-echo-area-message (user-login-name))

      (setq initial-major-mode 'fundamental-mode
            initial-scratch-message nil
            inhibit-startup-message t)

      ;; Disable some GUI distractions.
      (tool-bar-mode -1)
      ;; (scroll-bar-mode -1)
      (menu-bar-mode -1)
      (blink-cursor-mode 0)

      ;; Set up fonts early.
      (set-face-attribute 'default
                          nil
                          :height 80
                          :family "Fantasque Sans Mono")
      (set-face-attribute 'variable-pitch
                          nil
                          :family "DejaVu Sans")

;; https://github.com/integral-dw/org-bullets - The MELPA branch from the popular legacy package
(use-package org-bullets
  :init
  (setq org-bullets-bullet-list '("●" "○" "●" "○" "●" "◉" "○" "◆"))
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package company-emoji
  :config (add-to-list 'company-backends 'company-emoji))

(use-package org
  :bind (
    ("C-c l" . org-store-link)
  )
  :config
    ;; Add some todo keywords.
  ;; https://orgmode.org/list/8763vfa9hl.fsf@legolas.norang.ca/
  (setq org-log-done t
    org-use-fast-todo-selection t
    )
  ;; https://orgmode.org/manual/Dynamic-Headline-Numbering.html#Dynamic-Headline-Numbering (numbered headlines in orgmode)
  ;; https://lists.endsoftwarepatents.org/archive/html/emacs-orgmode/2020-03/msg00082.html - Turn on org-num-mode in init?
  ;; this require does not seem to be needed (anymore) ?
  (require 'org-num)
  (add-hook 'org-mode-hook #'org-num-mode)

 ;; M-x list-colors-display (https://www.gnu.org/software/emacs/manual/html_node/elisp/Color-Names.html)
 (setq org-todo-keyword-faces
       '(("TODO"  . (:foreground "red" :weight bold))
 	("NEXT"  . (:foreground "red" :weight bold))
 	("DONE"  . (:foreground "forest green" :weight bold))
 	("WAITING"  . (:foreground "orange" :weight bold))
 	("RETEST"  . (:foreground "brightred" :weight bold))
 	("CANCELLED"  . (:foreground "forest green" :weight bold))
 	("SOMEDAY"  . (:foreground "orange" :weight bold))
 	("OPEN"  . (:foreground "red" :weight bold))
 	("CLOSED"  . (:foreground "forest green" :weight bold))
 	("ONGOING"  . (:foreground "orange" :weight bold))))

 (setq org-todo-keywords
       '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
 	(sequence "WAITING(w@/!)" "RETEST(r@/!)" "|" "CANCELLED(c!/!)")
 	(sequence "SOMEDAY(s!/!)" "|")
 	(sequence "OPEN(O!)" "|" "CLOSED(C!)")
     	(sequence "ONGOING(o)" "|")))

;; Unfortunately org-mode tends to take over keybindings that
;; start with C-c.
(unbind-key "C-c SPC" org-mode-map)
(unbind-key "C-c w" org-mode-map))

(use-package moe-theme
    :config
    ;; Show highlighted buffer-id as decoration. (Default: nil)
(setq moe-theme-highlight-buffer-id t)

;; Resize titles (optional).
(setq moe-theme-resize-markdown-title '(1.5 1.4 1.3 1.2 1.0 1.0))
(setq moe-theme-resize-org-title '(1.5 1.4 1.3 1.2 1.1 1.0 1.0 1.0 1.0))
(setq moe-theme-resize-rst-title '(1.5 1.4 1.3 1.2 1.1 1.0))

;; Highlight Buffer-id on Mode-line
;; (setq moe-theme-highlight-buffer-id nil)

;; Choose a color for mode-line.(Default: blue)
(setq moe-theme-set-color 'cyan)

;; Finally, apply moe-theme now.
    ;; Choose what you like, (moe-light) or (moe-dark)
    ;; https://www.reddit.com/r/emacs/comments/3tpoae/usepackage_doesnt_load_theme/cx88myw
    :init
(load-theme 'moe-dark t))

(use-package deft
  :after (org-super-links)
  :bind ("C-<f12>" . deft)
  :init
    ;; https://github.com/EFLS/zd-tutorial/blob/80eb8b378db2e44dd9daeb7eb9d49d176fe7ea14/2020-04-17-1532%20Zetteldeft%20and%20Markdown.org
    ;; https://github.com/jrblevin/deft/issues/49#issuecomment-368605084
    (setq deft-extensions '("org")
          deft-text-mode 'org-mode
          deft-directory "~/meinzettelkasten"
          deft-recursive t
          ;; deft-new-file-format "%Y-%m-%dT%H%M"
          deft-use-filename-as-title t
          ;; I tend to write org-mode titles with #+title: (i.e., uncapitalized). Also other org-mode code at the beginning is written in lower case.
          ;; In order to filter these from the deft summary, let’s alter the regular expression:
          deft-strip-summary-regexp
           (concat "\\("
                   "[\n\t]" ;; blank
                   "\\|^#\\+[a-zA-Z_]+:.*$" ;;org-mode metadata
                   "\\)")
          ;; Its original value was \\([\n ]\\|^#\\+[[:upper:]_]+:.*$\\).
          )
)
(setq deft-default-extension "org")

(use-package zetteldeft
  :after (deft)
  :config
    (zetteldeft-set-classic-keybindings)
  :ensure t)

;; https://github.com/EFLS/zd-tutorial
(setq deft-directory "~/meinzettelkasten")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . nil)
   (shell . t)))

;; https://github.com/joostkremers/visual-fill-column - Emacs mode for wrapping visual-line-mode buffers at fill-column. See https://stackoverflow.com/a/4879934/3320256 and https://gitlab.com/ndw/dotfiles/-/blob/16a02b38bbf7c5a750f0009fcd19636b039d2006/emacs.d/emacs.org#L1136 as well
(setq line-move-visual nil)
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
(use-package visual-fill-column)
(add-hook 'visual-line-mode-hook #'visual-fill-column-mode)

(global-visual-line-mode)
(setq-default visual-fill-column-width 103)
(global-visual-fill-column-mode)

;; https://mstempl.netlify.app/post/beautify-org-mode/
(use-package org-bullets
  :custom
  (org-bullets-bullet-list '("◉" "☯" "○" "☯" "✸" "☯" "✿" "☯" "✜" "☯" "◆" "☯" "▶"))
  (org-ellipsis "⤵")
  :hook (org-mode . org-bullets-mode))
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([+]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "◦"))))))

;; i. e. https://github.com/DougBeney/emacs/blob/e55430a4c5fa6fc238676f3b3565f0afe6ee8e70/sanemacs.el#L56 does something annoying at least for me, see also https://stackoverflow.com/a/14164500/3320256 and for a cool workaround see https://emacs.stackexchange.com/questions/14438/remove-hooks-for-specific-modes
(remove-hook 'before-save-hook 'delete-trailing-whitespace)


;; TODO how to create a dynamic headline (rendered only) line in emacs

(deft)
'';
in
  {
    home.packages = [
      (pkgs.emacsWithPackagesFromUsePackage {
        config = builtins.readFile myEmacsConfig;
        package = pkgs.emacsUnstable-nox;
        extraEmacsPackages = epkgs: (with epkgs.melpaPackages; [
          # see https://nixos.org/manual/nixpkgs/stable/#sec-emacs
(pkgs.runCommand "default.el" {} ''
mkdir -p $out/share/emacs/site-lisp
  cp ${myEmacsConfig} $out/share/emacs/site-lisp/default.el
  cp ${saneEmacsEl} $out/share/emacs/site-lisp/sanemacs.el
  echo $out/share/emacs/site-lisp
'')
          #writeroom-mode
          #visual-fill-column
          # https://raw.githubusercontent.com/nix-community/emacs-overlay/8eaac8ad639b1ecb1c4add4cb581923876b2f31b/repos/melpa/recipes-archive-melpa.json it is contained
          #simpleclip
          #org-ref
        ]) ++ (with epkgs.elpaPackages; [
          #org
        ]);
      })
    ];

    home.file = {
      ".emacs.d/early-init.el".text = ''
(setq package-enable-at-startup nil)
(provide 'early-init)
          '';
    };
  }
