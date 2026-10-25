---
name: fix-conflict
description: |
  上流ブランチ（既定 main）を現在の作業ブランチに取り込み、merge / rebase で発生したコンフリクトを解消するスキル。
  ユーザーが「コンフリクト解消」「コンフリクト直して」「mainを最新化してコンフリクト直す」「mainに追従」「mainをマージ」「rebase でコンフリクト直して」「fix-conflict」などと言ったときに必ず使用すること。
  単純に `git merge` を流すだけでなく、両側の変更意図を読み解き、プロジェクトの規約 (CLAUDE.md・memory) を踏まえて解消し、typecheck と関連テストで検証してからコミットする。push は明示的に確認してから行う。
argument-hint: （省略可）対象の上流ブランチ名（デフォルト: main）／rebase か merge か
---

# コンフリクト解消スキル (fix-conflict)

現在のブランチに上流（既定では `origin/main`）を取り込み、コンフリクトを「両側の意図を理解した上で」解消する。完走条件は **typecheck + 関連テストがパスし、マージコミットが作成されている** こと。push は **必ずユーザーに確認** してから行う。

このスキルは「片側を捨てない」「検証してから commit する」「規約に沿う」の3点が肝。`-X theirs` / `-X ours` のような一括解消には絶対に頼らない。

## 前提とポリシー

- **デフォルトは merge**。rebase は対象ブランチがまだ push されていない／レビュー前で履歴を綺麗にしたい等、ユーザーが明示的に望んだ場合のみ。
- **CI=true を付けてテスト・typecheck を流す**（プロジェクトに `CI` 由来のフラグがある場合の標準）。
- **片側採用 (`--theirs` / `--ours` の機械的適用) はしない**。両側の変更意図を読んだ上でマージする。
- **push は確認してから**。マージが完了しても push は別アクション扱い。
- **作業ツリーが汚れていたら止まる**。stash / commit / 別作業の保留をユーザーに確認。

## 手順

### 1. 事前確認

```bash
git status
git branch --show-current
```

`working tree clean` でない場合はユーザーに確認。stash するか、先にコミットするか、中断するかを聞く。

### 2. 上流の最新化と差分の把握

```bash
git fetch origin <upstream>          # 既定: main
git log --oneline HEAD..origin/<upstream> | head -30   # 取り込む側のコミット
git log --oneline origin/<upstream>..HEAD | head -30   # こちらのコミット
git diff --name-only origin/<upstream>...HEAD          # こちら側で触ったファイル
git diff --name-only $(git merge-base HEAD origin/<upstream>) origin/<upstream>  # 上流側で触ったファイル
```

両側のファイル一覧の積集合 ＝ コンフリクトしやすい候補。事前に把握しておくと解消方針が立てやすい。

### 3. マージ実行 (またはユーザー指定で rebase)

```bash
git merge origin/<upstream> --no-commit --no-ff
```

`--no-commit` を付けるのは、コンフリクトがなくても一旦止めて中身を確認するため。コンフリクトがあれば automatic merge failed が出る。

rebase の場合は `git rebase origin/<upstream>` で、コンフリクト発生時は同じ流れで解消 → `git add` → `git rebase --continue`。

### 4. コンフリクトの読み解きと解消

`git status` で `Unmerged paths` を確認。各ファイルについて以下を実行:

1. **コンフリクトマーカーの中身を Read で読む**。`<<<<<<< HEAD` / `=======` / `>>>>>>> origin/<upstream>` の両側を確認。
2. **両側がなぜそう変わったか**を、関連ファイル・コミットメッセージから把握する。例:
   - 上流: 関連するリファクタや別 PR の前提となる変更
   - こちら: 進行中の作業（型 narrowing、API 変更、リネーム 等）
3. **両方の意図を満たす解消**を書く。よくあるパターン:
   - 上流が**ファイル分割／構造変更**を導入し、こちらが**型変更や中身の変更**をしている → 上流の構造を採用しつつ、こちら側の型・実装変更を再適用
   - 上流が**新規メンバー追加**、こちらが**既存メンバー変更** → 両方を含める
   - 同じ箇所を別意図で修正 → 上位の意図（ユーザー or PRの目的）に従って統合

#### 規約（重要）

メモリ・CLAUDE.md・近隣の既存コードから「このプロジェクトでの正解」を引き出すこと。例:

- **narrow な型を選ぶ**: `StackAnalyzer` のような wide union より、`APIAnalyzer` / `DatabaseAnalyzer` のような discriminator narrow を優先（直近のリファクタの方針）
- **命名規約**: `allowlist/denylist`（「ホワイトリスト/ブラックリスト」を避ける）など CLAUDE.md に列挙された語彙
- **インポートパス**: ファイル移動が絡む場合は新しい階層に合わせて `../` の数を直す
- **テスト前提**: `CI=true bun test ...` のようなプロジェクト固有の実行形式

判断に迷う場合は、解消する前にユーザーへ「上流側の X と、こちら側の Y、両立は Z で良いか」と一言確認する。

### 5. 検証

```bash
# プロジェクトに合わせてどちらか or 両方
CI=true bun typecheck                                 # ADeT-AI 系
CI=true bun test <変更があった範囲>                   # 全部走らせるより範囲を絞る方が速い
```

- typecheck で `DiagnosticsError` が残るなら、解消の型整合がまだ不完全。Edit で直す。
- 関連テストは「コンフリクトしたディレクトリ + その依存」を最低限カバーする。

`package.json` の `scripts` を読んで、プロジェクトに合うコマンド（`pnpm typecheck`、`yarn test`、`npm run check` など）を選ぶこと。bun 前提のメモリは ADeT-AI など個別プロジェクトで有効。

### 6. ステージとコミット

```bash
git add <解消したファイル>
git status                                           # All conflicts fixed but you are still merging を確認
git commit --no-edit                                 # デフォルトの "Merge remote-tracking branch ..." メッセージで OK
```

メッセージをカスタムしたい場合のみ `git commit -m "..."` にするが、merge コミットは原則デフォルトで十分。

rebase の場合は `git add` → `git rebase --continue` を残コンフリクトがなくなるまで繰り返す。

### 7. 結果報告と push 確認

ユーザーへ以下を報告:

- **コンフリクトファイル一覧**と**各ファイルの解消方針**（どちら側を基にして、何を再適用したか）
- **検証結果**（typecheck pass、テスト件数）
- **ローカルが origin より N コミット先行**している旨
- 末尾で **「push しますか？」と一言確認**

ユーザーが yes と返したら `git push`。force push が必要な状況（rebase 後など）は、対象ブランチ名と影響を明示してから `git push --force-with-lease`。`--force` 単体は使わない。

## アンチパターン

- `git checkout --theirs <file>` / `--ours <file>` で機械的に片側採用する。**理由**: 両側の意図のうち片方を捨てている。手動で両立させるのが原則。
- コンフリクトマーカーを残したままコミット。**回避**: `git diff --check` でマーカー残存を検出。
- 検証なしでコミット。**理由**: 構造変更が絡むコンフリクトは解消した瞬間は型が通っていないことが多い。typecheck を必ず通してから commit。
- `git merge --abort` を即座に提案する。**理由**: コンフリクトがあること自体は失敗ではない。abort は「方針を立て直す必要がある」とユーザーが判断した場合の最終手段。
- 確認なしの push、特に `--force`。

## 例: 直近の解消パターン (参考)

ファイル分割と型 narrowing が衝突したケース:

- 上流: `graphql.ts` を `graphql/index.ts` + `graphql/nestjs-graphql/` に分割
- こちら: `GRAPHQL_ANALYZERS` の型を `StackAnalyzer` → `APIAnalyzer` に narrowing
- 解消: 上流の分割構造を採用しつつ、`graphql/index.ts` と `nestjs-graphql/index.ts` 両方の型注釈を `APIAnalyzer` に書き換え、import パスも `../../types/analyzer` に補正
- 検証: `bun typecheck` pass、`bun test src/core/project/stack/` 72 pass
- コミット: デフォルトの merge メッセージで `git commit --no-edit`
