---
name: cmux-control
description: |
  cmuxのワークスペース/ペイン/ターミナル/ブラウザをCLI経由で観測・操作するスキル。
  ユーザが「cmuxを見て」「cmuxのターミナル/ブラウザを確認」「cmuxで〜を操作」「このブラウザをクリック」「サーバのログを見て」などと言った場合、またはローカルに起動中のdevサーバやブラウザ画面の状態を確認する必要があるときに使用する。
  ターミナルの画面読み取り (read-screen) とブラウザの snapshot / screenshot / click / type など Playwright風の操作が可能。
---

# cmux-control

cmux は Unix socket 経由で制御でき、現在開いているウィンドウ・ワークスペース・ペイン・サーフェス (ターミナル or ブラウザ) を観測・操作できる。スクショやDOM snapshot経由でブラウザ画面の中身をClaudeが読めるため「画面が見えない」と即断しないこと。

## 1. 構造把握

```bash
cmux tree --all            # 全ウィンドウ/ワークスペース/ペイン/サーフェスをツリー表示
cmux list-workspaces
cmux list-panes --workspace <id|ref>
cmux list-pane-surfaces --workspace <id|ref>
cmux current-workspace
```

参照は `workspace:1` `pane:3` `surface:8` のような短縮ref、UUID、インデックスのいずれでも可。`tree` の出力で `[terminal]` / `[browser]` が各サーフェスに付くのでそれで種類を判別する。

## 2. ターミナルサーフェスの観測

```bash
cmux read-screen --surface <surface> --lines 40          # 直近40行
cmux read-screen --surface <surface> --scrollback        # スクロールバック含む
cmux capture-pane --surface <surface> --lines 200        # tmux互換
```

dev server などプロセスのログ確認はまずこれ。ブラウザサーフェスに `read-screen` はエラー (`Surface is not a terminal`) になる。

## 3. ターミナルへの入力

```bash
cmux send --surface <surface> "任意のコマンド"
cmux send-key --surface <surface> Enter
cmux send-key --surface <surface> C-c
```

## 4. ブラウザサーフェスの観測

```bash
# DOMスナップショット (role/text/ref付き、clickなどで使う ref を取得できる)
cmux browser --surface <surface> snapshot --compact
cmux browser --surface <surface> snapshot --interactive   # インタラクティブ要素のみ
cmux browser --surface <surface> snapshot --selector "main"

# スクリーンショットをPNG保存 → Readツールで画像として読み込める
cmux browser --surface <surface> screenshot --out /tmp/page.png

# URLやテキストを直接取得
cmux browser --surface <surface> get url
cmux browser --surface <surface> get title
cmux browser --surface <surface> get text "h1"
cmux browser --surface <surface> get html
```

スクショは `/tmp/*.png` に出して `Read` ツールで読むのが定石。`snapshot` は `ref=e87` のような参照IDを返すので、それを click などの操作対象として使える (CSSセレクタや `browser find` との併用も可)。

## 5. ブラウザの操作

```bash
# ナビゲーション
cmux browser --surface <surface> goto <url> --snapshot-after
cmux browser --surface <surface> back
cmux browser --surface <surface> reload

# クリック/入力
cmux browser --surface <surface> click "text=Sign In"
cmux browser --surface <surface> fill "input[name=email]" "foo@example.com"
cmux browser --surface <surface> type "textarea" "hello"
cmux browser --surface <surface> press Enter
cmux browser --surface <surface> select "select#country" "JP"
cmux browser --surface <surface> scroll --dy 500

# 待機・確認
cmux browser --surface <surface> wait --selector ".ready" --timeout-ms 5000
cmux browser --surface <surface> wait --load-state complete
cmux browser --surface <surface> is visible ".error"

# ログ・エラー
cmux browser --surface <surface> console list
cmux browser --surface <surface> errors list

# JS実行
cmux browser --surface <surface> eval "document.title"

# タブ操作
cmux browser --surface <surface> tab list
cmux browser --surface <surface> tab new <url>
```

## 6. 新規サーフェス作成

```bash
cmux new-surface --type browser --url <url> --workspace <ws>
cmux new-pane --type terminal --direction right --workspace <ws>
cmux new-split right --workspace <ws>
```

## 7. 典型的な使いどころ

- dev serverのログを `read-screen` で取得してエラー有無を判定
- UI実装後に `browser reload` → `screenshot` / `snapshot` で実際の描画を確認 (型チェック・lintでは UI バグは検出できないため実機確認する)
- 複数ルートを `browser goto` で巡回して表示崩れ・コンソールエラー・404を検知
- E2E相当の操作 (ログイン→フォーム入力→遷移確認) を `click` / `fill` / `wait` で自動化
- `cmux send` でサーバ再起動やマイグレーションを別ペインで実行しつつ、別サーフェスのブラウザで確認

## 補足

- `--workspace` を省くと呼び出し元のワークスペースが使われるので、別ワークスペースを操作するときは明示する
- `cmux` 単体で全サブコマンド一覧。個別コマンドは引数なしで実行するとusageが出る
- 認証は `--password` 引数 > `CMUX_SOCKET_PASSWORD` env > Settings 保存パスワードの優先順
- サーフェスIDはcmux再起動などで変わるので、スクリプトで使い回すときは毎回 `tree` で取り直す
