;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Alexander Starovoytov"
      user-mail-address "stewk6@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Source Code Pro" :size 20 :weight 'semi-light)
     doom-variable-pitch-font (font-spec :family "DejaVu Sans" :size 21))

;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-tokyo-night)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/new/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(require 'ox-latex)
(setq org-latex-compiler "lualatex")
(add-to-list 'org-latex-packages-alist
             '("AUTO" "polyglossia" t ("xelatex" "lualatex")))
(setq org-latex-listings 'minted)
(add-to-list 'org-latex-packages-alist '("" "minted"))

(setq org-latex-minted-options '(("breaklines" "true")
                                 ("breakanywhere" "true")))

(setq org-latex-pdf-process
      '("lualatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "lualatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "lualatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

(setq org-preview-latex-process-alist
 '((dvipng :programs
          ("lualatex" "dvipng")
          :description "dvi > png" :message "you need to install the programs: latex and dvipng." :image-input-type "dvi" :image-output-type "png" :image-size-adjust
          (1.0 . 1.0)
          :latex-compiler
          ("lualatex -output-format=dvi -interaction nonstopmode -output-directory %o %f")
          :image-converter
          ("dvipng -D %D -T tight -o %O %f")
          :transparent-image-converter
          ("dvipng -D %D -T tight -bg Transparent -o %O %f"))
  (dvisvgm :programs
           ("latex" "dvisvgm")
           :description "dvi > svg" :message "you need to install the programs: latex and dvisvgm." :image-input-type "dvi" :image-output-type "svg" :image-size-adjust
           (1.7 . 1.5)
           :latex-compiler
           ("latex -interaction nonstopmode -output-directory %o %f")
           :image-converter
           ("dvisvgm %f -n -b min -c %S -o %O"))
  (imagemagick :programs
               ("latex" "convert")
               :description "pdf > png" :message "you need to install the programs: latex and imagemagick." :image-input-type "pdf" :image-output-type "png" :image-size-adjust
               (1.0 . 1.0)
               :latex-compiler
               ("pdflatex -interaction nonstopmode -output-directory %o %f")
               :image-converter
               ("convert -density %D -trim -antialias %f -quality 100 %O"))))

(setq org-format-latex-options
  '(:foreground default :background default :scale 2.0
		:html-foreground "Black" :html-background "Transparent"
		:html-scale 1.0 :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))

(map! "C-z" nil)

(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))
(setq company-idle-delay 0.6)

(setq org-timer-default-timer 25)

(add-hook 'org-clock-in-hook (lambda ()
      (if (not org-timer-current-timer)
      (org-timer-set-timer '(16)))))

;; ;; Uncomment the next line if you are using this from source
;; ;; (add-to-list 'load-path "<path-to-lsp-docker-dir>")
;; (require 'lsp-docker)

(defvar lsp-docker-client-packages
    '(lsp-css lsp-clients lsp-bash lsp-go lsp-pyls lsp-html lsp-typescript
      lsp-terraform lsp-clangd))

(setq lsp-docker-client-configs
    '((:server-id gopls :docker-server-id gopls-docker :docker-image-id "iu9-networks:latest" :docker-container-name "gopls-32" :server-command "gopls")))

(after! lsp-docker
  (lsp-docker-init-clients
   :path-mappings '(("/home/st/c/iu9-networks/lab3.2" . "/service")
                    ("/home/st/c/iu9-networks/lab3.2/.cache/go/mod" . "/go/mod")
                    ("/home/st/c/iu9-networks/lab3.2/.cache/go-build" . "/root/.cache/go-build")
                    ("/home/st/c/iu9-networks/lab3.2/.cache/golangci-lint" . "/root/.cache/golangci-lint"))

   :client-packages lsp-docker-client-packages
   :client-configs lsp-docker-client-configs))

(setq display-line-numbers 'relative)
(defun my/display-set-relative ()
  (setq display-line-numbers 'relative))     ; or 'visual

(defun my/display-set-absolute ()
  (setq display-line-numbers t))

(add-hook 'evil-insert-state-entry-hook #'my/display-set-absolute)
(add-hook 'evil-insert-state-exit-hook #'my/display-set-relative)
