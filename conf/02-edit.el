;;;;;;;;;;;;;;;;;;;;
;;; カーソル関連 ;;;
;;;;;;;;;;;;;;;;;;;;

;;; #削除系コマンド ;;;

;; C-k(kill-line)で行末の改行までkill
(setq kill-whole-line 1)

;; カーソル位置から行頭まで削除する
(defun backward-kill-line (arg)
  "Kill chars backward until encountering the end of a line."
  (interactive "p")
  (kill-line 0))

;; 範囲指定していないとき、C-wで前の単語を削除
(defadvice kill-region (around kill-word-or-kill-region activate)
  (if (and (interactive-p) transient-mark-mode (not mark-active))
      (backward-kill-word 1)
    ad-do-it))
;; minibuffer用
(define-key minibuffer-local-completion-map "\C-w" 'backward-kill-word)

;; カーソル位置の単語を削除
(defun kill-word-at-point ()
  (interactive)
  (let ((char (char-to-string (char-after (point)))))
    (cond
     ((string= " " char) (delete-horizontal-space))
     ((string-match "[\t\n -@\[-`{-~]" char) (kill-word 1))
     (t (forward-char) (backward-word) (kill-word 1)))))

;;; #移動系コマンド ;;;

;; ウィンドウ内のカーソル移動

;; 最後の変更箇所にジャンプする
; M-x install-elisp-from-emacswiki goto-chg.el
(require 'goto-chg)

;; カーソル位置を戻す
(require 'point-undo)
; M-x install-elisp-from-emacswiki point-undo.el

;;; #表示 ;;;

;; 相対的なカーソル位置を保ったまま画面スクロール
(setq scroll-preserve-screen-position t)

;;; 現在行・桁のハイライト
(defface hlline-face
  '((((class color)
      (background dark))
     (:background "dark slate gray"))
    (((class color)
      (background light))
     (:background  "#98FB98"))
    (t
     ()))
  "*Face used by hl-line.")
(setq hl-line-face 'hlline-face)
(global-hl-line-mode)

;;; #その他 ;;;

;; キーボード同時押しコマンドの設定
;; (require 'key-chord)
;; (setq key-chord-two-keys-delay 0.04)
;; (key-chord-mode 1)

;;; 同じキーバインドを連打すると警告を出す
;; (require 'dont-type-twice)
;; (global-dont-type-twice t)





;;;;;;;;;;;;;;;;;;;;
;;; 編集系の設定 ;;;
;;;;;;;;;;;;;;;;;;;;

;;; 矩形編集 ;;;
(cua-mode t)
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効に

;;; grep系 ;;;

;; M-x grep 検索結果を編集可能に
;; ack --nogroup hoge でackが使える
; M-x install-elisp-from-emacswiki grep-edit.el
(require 'grep-edit)

;;; その他;;;

;; tailモード
; M-x install-elisp-from-emacswiki tail.el
(require 'tail)
(setq tail-volatile nil)
(setq tail-hide-delay 100000)
(setq tail-max-size 15)





;;;;;;;;;;;;;;;;;;;;
;;; ファイル操作 ;;;
;;;;;;;;;;;;;;;;;;;;

;; バックアップファイルを作らない
(setq make-backup-files nil)

;; オートセーブファイルを作らない
;(setq auto-save-default nil)

;; オートセーブファイルを~/.emacs.d/backups/へ集める
;; M-x recover-file RET ~/.emacs.d/backups/hoge.hoge RET でバッファが復元される
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))

;; オートセーブファイル作成までの時間とタイプ間隔
(setq auto-save-timeout 15)
(setq auto-save-interval 60)

;; 終了時にオートセーブファイルを消す
(setq delete-auto-save-files t)

;; 最近使ったファイルを開く
(when (require 'recentf nil t)
  (setq recentf-max-saved-items 2000)
  (setq recentf-exclude '(".recentf" "/TAGS$" "/var/tmp/" "Map_Sym.txt"))
  (setq recentf-auto-cleanup 10)
  (setq recentf-auto-save-timer
        (run-with-idle-timer 30 t 'recentf-save-list))
  (recentf-mode 1)
  (require 'recentf-ext))

;; diredを便利にする
(require 'dired-x)

;; diredから"r"でファイル名をインライン編集する
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;; wdiredで、ファイルのパーミションを編集可能にする
;; "C-x d"でwdired、"C-x C-q"で編集モード
(setq wdired-allow-to-change-permissions t)

;; ファイル名が重複していたらディレクトリ名を追加する。
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; 現在カーソル位置のファイル・URLを開く
(ffap-bindings)

;;; direx ;;;
(defun my/dired-jump ()
  (interactive)
  (cond (current-prefix-arg
         (dired-jump))
        ((not (one-window-p))
         (or (ignore-errors
               (direx-project:jump-to-project-root) t)
             (direx:jump-to-directory)))
        (t
         (or (ignore-errors
               (direx-project:jump-to-project-root-other-window) t)
             (direx:jump-to-directory-other-window)))))

;; widthは環境に合わせて調整してください。
(push '(direx:direx-mode :position left :width 40 :dedicated t)
      popwin:special-display-config)





;;;;;;;;;;;;;;;;
;;; 履歴操作 ;;;
;;;;;;;;;;;;;;;;

;;; #undo,redo ;;;
; packageでインストール
(require 'undo-tree)
(global-undo-tree-mode t)

;;; #履歴の保存 ;;;

;; 履歴を次回emacs起動畤にも保存する
(savehist-mode 1)

;; 履歴数を大きくする
(setq history-length t)

;; kill-ringやミニバッファで過去に開いたファイルなどの履歴を保存する
; install-elisp-from-emacswiki session.el
(when (require 'session nil t)
  (setq session-initialize '(de-saveplace session keys menus places)
        session-globals-include '((kill-ring 50)
                                  (session-file-alist 500 t)
                                  (file-name-history 10000)))
  (add-hook 'after-init-hook 'session-initialize)
  (setq session-undo-check -1)) ; 前回閉じたときの位置にカーソルを復帰





;;;;;;;;;;;;;;;;;;;;;;;;
;;; ルート権限で編集 ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; サーバーemacsclientとして開く
;; ;; ~/bashrcに export EDITOR=emacsclient export VISUAL=emacsclient を追加しておく
;; (server-start)
;; (defun iconify-emacs-when-server-is-done ()
;;   (unless server-clients (iconify-frame)))
;; ;; 編集が終了したらEmacsをアイコン化する
;; (add-hook 'server-done-hook 'iconify-emacs-when-server-is-done)
;; ;; C-x C-cに割り当てる
;; (global-set-key (kbd "C-x C-c") 'server-edit)
;; ;; M-x exitでemacsを終了出来るようにする
;; (defalias 'exit 'save-buffers-kill-emacs)

;; ;; sudoを使う
;; (server-start)
;; (require 'sudo-ext)





;;;;;;;;;;;;;;;;
;;; メモ管理 ;;;
;;;;;;;;;;;;;;;;

;; org-mode
;; Emacsでメモ・TODO管理
(require 'org-install)
(when (< emacs-major-version 24)
  (define-key global-map "\C-cl" 'org-store-link)
  (define-key global-map "\C-ca" 'org-agenda)
  (define-key global-map "\C-cr" 'org-remember)
  (setq org-startup-truncated nil)
  (setq org-return-follows-link t)
  (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
  (org-remember-insinuate)
  (setq org-directory "~/memo/")
  (setq org-default-notes-file (concat org-directory "notes.org"))
  (setq org-agenda-files '("~/memo/notes.org"))
  (setq org-remember-templates
        '(("Todo" ?t "** TODO %?\n   %i\n   %a\n   %t" nil "Inbox")
          ("Bug" ?b "** TODO %?   :bug:\n   %i\n   %a\n   %t" nil "Inbox")
          ("Idea" ?i "** %?\n   %i\n   %a\n   %t" nil "New Ideas"))))

;; 試行錯誤用ファイル
; M-x install-elisp-from-emacswiki open-junk-file.el
(require 'open-junk-file)
(setq open-junk-file-format "~/junk/%Y-%m-%d-%H%M%S.")
