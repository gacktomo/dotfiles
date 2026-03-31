---
name: debug-spec-analyze
description: spec-analyzeのデバッグ用スキル。analyze-specをtenpla-coreプロジェクト向けのテスト環境変数で実行し、出力をタイムスタンプ付きログファイルに保存する。既存の生成済みSpecファイルを確認する手順も提供する。ユーザーが「spec-analyzeを実行」「analyze-specをデバッグ」「specを再生成」「Specの確認」などと言った場合に使用すること。
argument-hint: （省略可）確認したいSPEC_SECTIONSや追加の環境変数
---

# debug-spec-analyze

`tenpla-core` プロジェクト向けの spec-analyze デバッグスキル。

## analyze-spec の実行

以下のコマンドを実行する。stdout/stderr はログファイルに保存されるのでデバッグ時はそちらを参照すること。

```bash
LOG_FILE="/tmp/tenpla-core-ProjectSpecification_$(date +%Y%m%d_%H%M%S).log"
echo "Log file: $LOG_FILE"
time ADET_USER_ID=test-user \
  ADET_PROJECT_ID=test-project \
  DEBUG_LOCAL_PROJECT_PATH=/Users/omatsu/ghq/github.com/Accel-Hack/tenpla-core \
  PROJECT_OVERVIEW_URL=http://127.0.0.1:8080/tenpla-core-PROJECT_OVERVIEW.md \
  SPEC_SNAPSHOT_URL=http://127.0.0.1:8080/tenpla-core-ProjectSpecification.json \
  DEBUG_SPEC_SECTIONS=screen \
  GIT_DIFF_BASE=main \
  GIT_DIFF_HEAD=diff-test \
  bun --env-file=.env src/analyze-spec/index.ts \
  > "$LOG_FILE" 2>&1
echo "Exit code: $?"
grep '"tag":"request_metrics"' "$LOG_FILE" \
  | jq -r '.args[0] | "総コスト: \(.totalCost)¢ / 所要時間(AI): \(.totalDurationSec)秒 / コール数: \(.totalCallCount)"'
```

### 注意事項

- 実行前に作業ディレクトリが ADeT-AI プロジェクトルートであることを確認する
- stdout/stderr を `2>&1` でまとめてログファイルに保存する（Bunのエラーも捕捉するため）
- ログ出力は大量になるため、コンソール出力は省略し `$LOG_FILE` のパスをユーザーに伝える
- 詳細実行数を絞る必要がある場合はDEBUG_DETAIL_LIMIT=1を指定すること

## ログの確認

```bash
# INFOログのみ抽出して進捗・完了確認（推奨）
grep '"level":"INFO"' <LOG_FILE> | jq -r '.args[0]'
```

成功時の末尾:
```
Specification agent completed successfully
Analyze-Spec Completed!
```

失敗時:
```
Specification agent failed
```

```bash
# 詳細なDEBUGログも含めて全確認
cat <LOG_FILE> | jq '.'
```

## 生成済み Spec の確認

Spec ファイルは2種類存在する。用途に応じて使い分けること。

| ファイル | 役割 |
|----------|------|
| `~/Documents/adet/tenpla-core-ProjectSpecification.json` | **差分生成のベース** (`SPEC_SNAPSHOT_URL` で参照される既存Spec) |
| `/tmp/ProjectSpecification.json` | **今回の実行で新たに生成されたSpec** (`index.ts` が書き出す出力先) |

```bash
# --- 新たに生成されたSpec（/tmp）の確認 ---

# screens の件数
cat /tmp/ProjectSpecification.json | jq '.screens | length'

# screens の一覧（system_id + code + name + layouts数 + items数）
cat /tmp/ProjectSpecification.json \
  | jq -c '.screens[] | [.system_id, .code, .name, (.layouts|length), (.items|length)]'

# 特定の screen の詳細
cat /tmp/ProjectSpecification.json \
  | jq '.screens[] | select(.code == "SCREEN_CODE")'


# --- ベースSpec（~/Documents/adet）の確認 ---

# screens の一覧（system_id + name）
cat ~/Documents/adet/tenpla-core-ProjectSpecification.json \
  | jq -c '.screens | sort_by(.system_id)[] | [.system_id, .name]'

# screens の件数確認
cat ~/Documents/adet/tenpla-core-ProjectSpecification.json \
  | jq '.screens | length'
```

## 差分更新の動作確認

差分更新モード（`GIT_DIFF_BASE` / `GIT_DIFF_HEAD` 指定時）では以下を確認する:

```bash
# Screen pipeline のサマリ（INFOログから）
grep '"level":"INFO"' <LOG_FILE> | jq -r 'select(.tag == "specification") | .args[0]'
# 期待: "Screen pipeline: X to detail, Y unchanged, Z deleted"

# create: 新しいsystem_idが発行され、layouts/itemsが生成されていること
# update: 既存のsystem_idが維持されていること
# delete: 出力Specから該当screenが除外されていること
# unchanged: 元のlayouts/itemsが保持されていること
cat /tmp/ProjectSpecification.json \
  | jq -c '.screens[] | [.system_id, .code, (.layouts|length), (.items|length)]'
```

## 手順

1. コマンドを実行し、`$LOG_FILE` のパスをユーザーに伝える
2. 実行完了後、INFOログで成功/失敗を確認する
3. 差分更新モードの場合は「差分更新の動作確認」セクションの手順で検証する
4. 必要に応じてベースSpecとの比較を jq で確認する
