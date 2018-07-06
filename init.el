;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; load path                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; add load-path
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; (add-to-load-path "elisp" "conf" "public_repos")

;; custom file
(setq custom-file (locate-user-emacs-file "custom.el"))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; add repo                                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'cl-lib)
(require 'package)

(add-to-list
 'package-archives
 '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general settings                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; backup
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))
(setq auto-save-timeout 15)
(setq auto-save-interval 60)

;; add path
(cl-loop for x in (reverse
                (split-string (substring (shell-command-to-string "echo $PATH") 0 -1) ":"))
      do (add-to-list 'exec-path x))

;; (when (memq window-system '(mac ns x))
;;   (exec-path-from-shell-initialize))

;; recentf
(when (require 'recentf nil 'noerror)
  (setq recentf-max-saved-items 1000)
  (setq recentf-exclude '("recentf"))
  (setq recentf-auto-save-timer
        (run-with-idle-timer 30 t 'recentf-save-list))
  (recentf-mode 1))

;; don't create frames
(setq ns-pop-up-frames nil)

;; TRAMPでバックアップファイルを作成しない
(add-to-list 'backup-directory-alist
             (cons tramp-file-name-regexp nil))

;; Mac
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

(when window-system
  ;; tool bar
  (tool-bar-mode 0)
  ;; scroll bar
  (scroll-bar-mode 0))

(unless (eq window-system 'ns)
  ;; menu bar
  (menu-bar-mode 0))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; startup message
(setq inhibit-startup-screen t)
;; column number
(column-number-mode t)
;; line number
(line-number-mode 0)
;;(global-linum-mode 1)
;; file size
(size-indication-mode t)
;; file name
(setq frame-title-format "%f")
;; tab width
(setq-default tab-width 4)
;; use tab
(setq-default indent-tabs-mode nil)
;; file auto revert
(global-auto-revert-mode t)

;; リージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
(defun count-lines-and-chars ()
  (if mark-active
      (format "(%dlines,%dchars) "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
    ""))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key map                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; C-h => back space, C-? => help
(keyboard-translate ?\C-h ?\C-?)
(global-set-key (kbd "C-m") 'newline-and-indent)
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
(define-key global-map (kbd "C-t") 'other-window)

;; (add-to-list 'default-mode-line-format
;;              '(:eval (count-lines-and-chars)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; whitespace                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; display spaces and tabs
(setq whitespace-display-mappings
      '(
        (space-mark ?\x3000 [?\□]) ; zenkaku space
        ;; (newline-mark 10 [182 10]) ; ¶
        (tab-mark 9 [187 9] [92 9]) ; tab » 187
        ))

(setq whitespace-style
      '(
        spaces
        trailing
        newline
        space-mark
        tab-mark
        newline-mark))

;; display zenkaku space
(setq whitespace-space-regexp "\\(\u3000+\\)")

(global-whitespace-mode t)
(define-key global-map (kbd "<f5>") 'global-whitespace-mode)
(set-face-foreground 'whitespace-newline "Gray")

;; delete whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; dtwをdelete-trailing-whitespaceのエイリアスにする
;; (defalias 'dtw 'delete-trailing-whitespace)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; package                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; paren-mode
(setq show-paren-delay 0)
(show-paren-mode t)
(setq show-paren-style 'parenthesis)

;; undohist
(package-install 'undohist)
(when (require 'undohist nil t)
  (undohist-initialize))

;; undo-tree
(package-install 'undo-tree)
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))

;; ElScreen
(package-install 'elscreen)
(when (require 'elscreen nil t)
  (elscreen-start)
  ;; タブの先頭に[X]を表示しない
  (setq elscreen-tab-display-kill-screen nil)
  ;; header-lineの先頭に[<->]を表示しない
  (setq elscreen-tab-display-control nil))

;; cua-mode
(cua-mode t)
(setq cua-enable-cua-keys nil)

;; web-mode
(package-install 'web-mode)
(when (require 'web-mode nil t)
  ;; 自動的にweb-modeを起動したい拡張子を追加する
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  ;;; web-modeのインデント設定用フック
  ;; (defun web-mode-hook ()
  ;;   "Hooks for Web mode."
  ;;   (setq web-mode-markup-indent-offset 2) ; HTMLのインデイント
  ;;   (setq web-mode-css-indent-offset 2) ; CSSのインデント
  ;;   (setq web-mode-code-indent-offset 2) ; JS, PHP, Rubyなどのインデント
  ;;   (setq web-mode-comment-style 2) ; web-mode内のコメントのインデント
  ;;   (setq web-mode-style-padding 1) ; <style>内のインデント開始レベル
  ;;   (setq web-mode-script-padding 1) ; <script>内のインデント開始レベル
  ;;   )
  ;; (add-hook 'web-mode-hook  'web-mode-hook)
  )

;; less-css-mode
(package-install 'less-css-mode)

;; sass-mode
(package-install 'sass-mode)

;; php-mode
(package-install 'php-mode)
(require 'php-mode)
(defun php-indent-hook ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  ;; (c-set-offset 'case-label '+) ; switch文のcaseラベル
  (c-set-offset 'arglist-intro '+) ; 配列の最初の要素が改行した場合
  (c-set-offset 'arglist-close 0)) ; 配列の閉じ括弧
(add-hook 'php-mode-hook 'php-indent-hook)

;; phpunit.el
;; (package-install 'phpunit)
;; php-modeにキーバインドを追加する
;; (define-key php-mode-map (kbd "C-t t") 'phpunit-current-test)
;; (define-key php-mode-map (kbd "C-t c") 'phpunit-current-class)
;; (define-key php-mode-map (kbd "C-t p") 'phpunit-current-project)

;; yaml-mode
(package-install 'yaml-mode)

;; ruby-electric
(package-install 'ruby-electric)
(add-hook 'ruby-mode-hook #'ruby-electric-mode)

;; python-mode
(setq python-check-command "flake8")

;; Flycheck
;;(package-install 'flycheck)
;; 文法チェックを実行する
;;(add-hook 'after-init-hook #'global-flycheck-mode)

;; quickrunによるコード実行
(package-install 'quickrun)

;; gtagsとEmacsの連携
(package-install-file "/usr/local/share/gtags/gtags.el")

;; gtags-modeのキーバインドを有効化する
(setq gtags-suggested-key-mapping t) ; 無効化する場合はコメントアウト
;; ファイル保存時に自動的にタグをアップデートする
(setq gtags-auto-update t) ; 無効化する場合はコメントアウト

;; Helmとgtagsの連携
(package-install 'helm-gtags)
(custom-set-variables
 '(helm-gtags-suggested-key-mapping t)
 '(helm-gtags-auto-update t))

;; projectile
(package-install 'projectile)
(when (require 'projectile nil t)
  ;;自動的にプロジェクト管理を開始
  (projectile-mode)
  ;; プロジェクト管理から除外するディレクトリを追加
  (add-to-list
    'projectile-globally-ignored-directories
    "node_modules")
  ;; プロジェクト情報をキャッシュする
  (setq projectile-enable-caching t))

;; projectileのプレフィックスキーをs-pに変更
;; (define-key projectile-mode-map
;;   (kbd "s-p") 'projectile-command-map)

;; Helmを使って利用する
(package-install 'helm-projectile)
;; Fuzzyマッチを無効にする。
;; (setq helm-projectile-fuzzy-match nil)
(when (require 'helm-projectile nil t)
  (setq projectile-completion-system 'helm))

;; Railsサポートを利用して編集するファイルを切り替える
(package-install 'projectile-rails)
;; projectile-railsのプレフィックスキーをs-rに変更
;; (setq projectile-rails-keymap-prefix (kbd "s-r"))
(when (require 'projectile-rails nil t)
  (projectile-rails-global-mode))

;; Magit
(package-install 'magit)

;; git-gutter
(package-install 'git-gutter)
(when (require 'git-gutter nil t)
  (global-git-gutter-mode t)
  )

;; ediffコントロールパネルを別フレームにしない
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; multi-term
(package-install 'multi-term)
;; multi-termの設定
;; (when (require 'multi-term nil t)
(setq multi-term-program "/bin/bash")

;; WoMan
;; キャッシュを作成
(setq woman-cache-filename "~/.emacs.d/.wmncach.el")
;; manパスを設定
(setq woman-manpath '("/usr/share/man"))

;; Helmによるman検索
;; 既存のソースを読み込む
(require 'helm-elisp)
(require 'helm-man)
;; 基本となるソースを定義
(setq helm-for-document-sources
      '(helm-source-info-elisp
        helm-source-info-cl
        helm-source-info-pages
        helm-source-man-pages))
;; helm-for-documentコマンドを定義
(defun helm-for-document ()
  "Preconfigured `helm' for helm-for-document."
  (interactive)
  (let ((default (thing-at-point 'symbol)))
    (helm :sources
          (nconc
           (mapcar (lambda (func)
                     (funcall func default))
                   helm-apropos-function-list)
           helm-for-document-sources)
          :buffer "*helm for docuemont*")))

;; theme
(package-install 'color-theme-sanityinc-tomorrow)
(load-theme 'sanityinc-tomorrow-bright t)

;; company
(package-install 'company)
(global-company-mode)

;; undo-tree
(package-install 'undo-tree)
(global-undo-tree-mode t)
(global-set-key (kbd "M-/") 'undo-tree-redo)

;; neotree
(package-install 'neotree)
(package-install 'all-the-icons)
(global-set-key [f8] 'neotree-toggle)
(setq neo-smart-open t)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

;; helm
(package-install 'helm)
(global-set-key (kbd "M-x") 'helm-M-x)
(require 'helm-config)

;; highlight-indent-guides
(package-install 'highlight-indent-guides)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)

;; Ruby
(setq ruby-insert-encoding-magic-comment nil)

(electric-pair-mode t)

;; dired
(setq dired-dwim-target t)
(setq dired-isearch-filenames t)
