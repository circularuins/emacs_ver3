;;;;;;;;;;;;;;;;;;;;
;;; カーソル関連 ;;;
;;;;;;;;;;;;;;;;;;;;

;;; #削除系コマンド ;;;

;; C-hで直前の文字を消去
;(global-set-key (kbd "C-h") 'delete-backward-char)
(keyboard-translate ?\C-h ?\C-?)

;; C-x C-hでhelp
(global-set-key (kbd "C-x C-h") 'help)

;; C-k(kill-line)で行末の改行までkill
(setq kill-whole-line 1)

;; カーソル位置から行頭まで削除する
(defun backward-kill-line (arg)
  "Kill chars backward until encountering the end of a line."
  (interactive "p")
  (kill-line 0))
;; C-M-kに設定
(global-set-key (kbd "C-M-k") 'backward-kill-line)

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
(global-set-key "\M-d" 'kill-word-at-point)

;;; #移動系コマンド ;;;

;; ウィンドウ内のカーソル移動
(global-set-key (kbd "C-M-h") (lambda () (interactive) (move-to-window-line 0))) ; 画面上に移動
(global-set-key (kbd "C-M-m") (lambda () (interactive) (move-to-window-line nil))) ; 画面中に移動
(global-set-key (kbd "C-M-l") (lambda () (interactive) (move-to-window-line -1))) ; 画面下に移動

;; 最後の変更箇所にジャンプする
; M-x install-elisp-from-emacswiki goto-chg.el
(require 'goto-chg)
(define-key global-map (kbd "<f8>") 'goto-last-change)
(define-key global-map (kbd "S-<f8>") 'goto-last-change-reverse)

;; カーソル位置を戻す
(require 'point-undo)
; M-x install-elisp-from-emacswiki point-undo.el
(define-key global-map (kbd "<f7>") 'point-undo)
(define-key global-map (kbd "S-<f7>") 'point-redo)

;; 同じコマンドを連続実行した時の振る舞いを変更する
;; C-a連続：行頭→ファイル頭→元 C-e連続：行末→ファイル末→元
;; M-u(upcase),M-l(downcase),M-c(capitalize)が、カーソル直前の単語に効くようになる。連打すると、前方の単語を順次変換
(require 'sequential-command-config)
(sequential-command-setup-keys)

;; 連続して操作する際のprefixキー入力をキャンセルさせる
;; http://sheephead.homelinux.org/2011/12/19/6930/
(require 'smartrep)

;;; #表示 ;;;

;; 相対的なカーソル位置を保ったまま画面スクロール
(setq scroll-preserve-screen-position t)

;;; カーソル位置に目に見える印をつける
;; (setq-default bm-buffer-persistence nil)
;; (setq bm-restore-repository-on-load t)
;; (require 'bm)
;; (add-hook 'find-file-hooks 'bm-buffer-restore)
;; (add-hook 'kill-buffer-hook 'bm-buffer-save)
;; (add-hook 'after-save-hook 'bm-buffer-save)
;; (add-hook 'after-revert-hook 'bm-buffer-restore)
;; (add-hook 'vc-before-checkin-hook 'bm-buffer-save)
;; (global-set-key (kbd "M-SPC") 'bm-toggle)
;; (global-set-key (kbd "M-[") 'bm-previous)
;; (global-set-key (kbd "M-]") 'bm-next)

;;; 現在行・桁のハイライト
;; (require 'crosshairs)
;; (global-set-key (kbd "C-c h") 'crosshairs-mode)

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

;; cua-mode
;; C-RETで開始、C-gで終了
;; #連番入力の手順
;; 矩形選択後、M-oでスペース1文字挿入
;; M-n 後、初期値、加算値、フォーマットの順に入力
(cua-mode t)
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効に
; ターミナルでデフォルトの"C-RET"が使えないので変更する
(define-key global-map (kbd "C-x C-x") 'cua-set-rectangle-mark)

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

;; 最近開いたファイルを保存する数を増やす
(setq recentf-max-saved-items 10000)

;; 最近使ったファイルを開く
; M-x install-elisp-from-emacswiki recentf-ext.el
(setq recentf-exclude '("/TAGS$" "/var/tmp/" "Map_Sym.txt")) ; リストからの除外対象
(require 'recentf-ext)
(define-key global-map (kbd "C-x C-m") 'recentf-open-files)

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
;; C-u C-x C-j で、通常のdiredを実行
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

(global-set-key (kbd "C-x C-j") 'my/dired-jump)

;; widthは環境に合わせて調整してください。
(push '(direx:direx-mode :position left :width 40 :dedicated t)
      popwin:special-display-config)





;;;;;;;;;;;;;;;;
;;; 履歴操作 ;;;
;;;;;;;;;;;;;;;;

;;; #undo,redo ;;;

;; undoの分岐を視覚化(C-x u)
;; "p","n"で履歴を移動、"f","b"でブランチの切り替え、"q"で終了
; packageでインストール
(require 'undo-tree)
(global-undo-tree-mode t)
(global-set-key (kbd "M-/") 'undo-tree-redo)

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
(global-set-key (kbd "C-x C-z") 'open-junk-file)
