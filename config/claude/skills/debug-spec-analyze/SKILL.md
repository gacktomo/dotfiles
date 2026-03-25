---
name: debug-spec-analyze
description: spec-analyzeのデバッグ用スキル。analyze-specをtenpla-coreプロジェクト向けのテスト環境変数で実行し、出力をタイムスタンプ付きログファイルに保存する。既存の生成済みSpecファイルを確認する手順も提供する。ユーザーが「spec-analyzeを実行」「analyze-specをデバッグ」「specを再生成」「Specの確認」などと言った場合に使用すること。
argument-hint: （省略可）確認したいSPEC_SECTIONSや追加の環境変数
---

# debug-spec-analyze

`tenpla-core` プロジェクト向けの spec-analyze デバッグスキル。

## analyze-spec の実行

以下のコマンドを実行する。標準出力はログファイルに保存されるのでデバッグ時はそちらを参照すること。

```bash
time ADET_USER_ID=test-user \
  ADET_PROJECT_ID=test-project \
  LOCAL_PROJECT_PATH=/Users/omatsu/ghq/github.com/Accel-Hack/tenpla-core \
  PROJECT_OVERVIEW_URL=http://127.0.0.1:8080/tenpla-core-PROJECT_OVERVIEW.md \
  SPEC_SNAPSHOT_URL=http://127.0.0.1:8080/tenpla-core-ProjectSpecification.json \
  SPEC_SECTIONS=screen \
  GIT_DIFF_BASE=main \
  GIT_DIFF_HEAD=diff-test \
  DETAIL_LIMIT=1 \
  bun --env-file=.env src/analyze-spec/index.ts \
  > /tmp/tenpla-core-ProjectSpecification_$(date +%Y%m%d_%H%M%S).log
```

### 注意事項

- 実行前に作業ディレクトリが ADeT-AI プロジェクトルートであることを確認する
- 標準出力は大量になるため、コンソール出力は省略し `/tmp/tenpla-core-ProjectSpecification_*.log` のログファイルを確認するよう案内する
- ログファイルのパスは実行後に `ls -lt /tmp/tenpla-core-ProjectSpecification_*.log | head -1` で最新のものを確認できる

## ログの確認

最新のログファイルを確認する:

```bash
# 最新ログファイルのパスを取得
ls -lt /tmp/tenpla-core-ProjectSpecification_*.log | head -1

# ログの末尾を確認（エラーや完了ステータス）
tail -50 /tmp/tenpla-core-ProjectSpecification_<timestamp>.log

# JSON行のみ抽出
grep '^{' /tmp/tenpla-core-ProjectSpecification_<timestamp>.log | jq '.'
```

## 既存の生成済み Spec の確認

生成済みの Spec ファイルはサイズが大きいため、jq でフィルタして必要な箇所のみ確認する。

```bash
# screens の一覧（system_id + name）
cat ~/Documents/adet/tenpla-core-ProjectSpecification.json \
  | jq -c '.screens | sort_by(.system_id)[] | [.system_id, .name]'

# 特定の screen の詳細
cat ~/Documents/adet/tenpla-core-ProjectSpecification.json \
  | jq '.screens[] | select(.system_id == "SCREEN_ID")'

# screens の件数確認
cat ~/Documents/adet/tenpla-core-ProjectSpecification.json \
  | jq '.screens | length'

# ファイル全体（大きいので注意）
cat ~/Documents/adet/tenpla-core-ProjectSpecification.json
```

## 手順

1. コマンドを実行する（バックグラウンド推奨）
2. ログファイルのパスをユーザーに伝える
3. 実行完了後、ログの末尾でエラーや完了ステータスを確認する
4. 必要に応じて既存 Spec との差分を jq で確認する
