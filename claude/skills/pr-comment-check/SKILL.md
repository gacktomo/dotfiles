---
name: pr-comment-check
description: |
  GitHub Pull Request に来たコメント（review comments / issue comments / review threads）を取得し、対応要否・優先度・対応方針を整理するスキル。
  ユーザーが「PRのコメント確認」「PRレビューコメント整理」「PRに来たコメント見て」「レビュー指摘の対応方針を整理」「pr-comment-check」「PRコメントチェック」などと言った場合に必ず使用すること。
  単に「PRレビュー」と言われた場合でも、自分が出したPRに対するレビューコメントを確認したい意図なら使う（自分が他人のPRをレビューする場合は別スキル）。
  resolved / outdated 状態を考慮し、各コメントを「対応必須 / 対応推奨 / 要相談 / 対応不要」に分類し、その理由と対応方針案を提示する。
argument-hint: （省略可）PR番号またはPR URL。省略時は現在のブランチに紐づくPRを自動検出
---

# PRコメント整理スキル (pr-comment-check)

自分が出した GitHub PR に来たコメントを取得し、対応要否を整理する。
人間レビュアーのコメントだけでなく、CodeRabbit / Codex などのAIレビュアーのコメントも対象にする。

## 設計の前提

PR コメントは GitHub 上で **3つの異なるエンドポイント** に分散して保存されている。これを混同するとコメントを取りこぼす。

| 種別 | 説明 | 取得API |
|---|---|---|
| **Review comments** | コード行に紐づくインラインコメント | `/repos/{o}/{r}/pulls/{n}/comments` |
| **Issue comments** | 会話タブ（Conversation）の汎用コメント | `/repos/{o}/{r}/issues/{n}/comments` |
| **Review threads** | レビュースレッド（resolved状態を含む） | GraphQL `reviewThreads` |
| **Reviews** | レビュー全体のサマリ（approve/request-changes/comment） | `/repos/{o}/{r}/pulls/{n}/reviews` |

resolved / outdated 状態は REST では取得できないため **GraphQL を使う**。これがこのスキルの肝。

## 手順

### 1. 対象PRの特定

引数で PR 番号 / URL が渡されていればそれを使う。なければ現在のブランチに紐づく PR を検出する。

```bash
# 引数が PR URL の場合
# 例: https://github.com/Owner/Repo/pull/123 → owner=Owner repo=Repo number=123

# 引数が番号のみの場合 → リポジトリは現在のディレクトリから取得
gh repo view --json owner,name -q '.owner.login + "/" + .name'

# 引数なしの場合 → 現在のブランチからPRを特定
gh pr view --json number,url,title,headRefName,baseRefName
```

PR が見つからなければユーザーに番号を尋ねる。

### 2. コメントの取得

resolved/outdated を含めて一度に取得するため、GraphQL を使う。

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      title
      url
      author { login }
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          isCollapsed
          path
          line
          comments(first: 50) {
            nodes {
              author { login }
              body
              createdAt
              url
            }
          }
        }
      }
      comments(first: 100) {
        nodes {
          author { login }
          body
          createdAt
          url
        }
      }
      reviews(first: 50) {
        nodes {
          author { login }
          state
          body
          submittedAt
          url
        }
      }
    }
  }
}' -F owner=<OWNER> -F repo=<REPO> -F number=<NUMBER>
```

> 補足: REST しか使えない環境なら `gh pr view <N> --json comments,reviews` + `gh api repos/.../pulls/N/comments` で代替できるが、resolved 判定が落ちるため精度が下がる。

### 3. コメントの分類とトリアージ

取得した各コメントを以下の軸で評価する。

#### 3-1. まず除外すべきもの

- **自分のコメント**: PR 作者自身（`gh api user -q .login` で取得）の発言は対応対象外。
- **resolved スレッド**: 既に解決済み（`isResolved: true`）。原則スキップするが、解決理由が不明瞭なものは「確認済み」として一覧に残す。
- **outdated スレッド**: コメント対象行が変更済み（`isOutdated: true`）。コメント内容を読んで、指摘が新しいコードでも当てはまるかを判断する。

#### 3-2. 残ったコメントを4段階で分類

| ラベル | 基準 | 例 |
|---|---|---|
| 🔴 **対応必須** | バグ・セキュリティ・契約違反・テスト失敗の原因など、放置するとマージ後に実害が出るもの | null チェック漏れ、SQL インジェクション、規約違反 |
| 🟡 **対応推奨** | 可読性・保守性・パフォーマンスの改善提案。多くのケースで取り込むべきだがブロッカーではない | 命名改善、共通化、早期 return |
| 🔵 **要相談** | 設計判断が必要なもの、PRスコープを超えるもの、トレードオフが伴うもの | アーキテクチャ変更、別PRに切り出すべきか、他チームへの影響 |
| ⚪ **対応不要** | 質問・確認のみ・既存仕様と整合・好みの問題でこのリポジトリの慣習と異なる | 「これってXX？」→ 回答だけで済む、スタイル指摘だが既存コードと統一されている |

判断する際の観点:

- **指摘の根拠**: 具体的な技術的理由があるか、それとも「なんとなく」か
- **影響範囲**: 何人に・どこに影響するか
- **修正コスト vs 価値**: 大きな書き直しを要求しているなら「要相談」が無難
- **PR のスコープ**: PR の主目的から外れる指摘は「要相談」または別 issue 化を提案
- **既存コードとの一貫性**: 周辺コードと矛盾するスタイルを要求していないか
- **AIレビュアー特有の偏り**: CodeRabbit / Codex は網羅的だが文脈を読み違えることがある。一見もっともらしい指摘でも、テストが既にカバーしていたり、別の場所で対応済みのケースを見落としていることがあるので、根拠を確認する

### 4. 出力フォーマット

以下の構造でユーザーに提示する。

```markdown
# PR #<番号> コメント整理

**タイトル**: <PR タイトル>
**URL**: <PR URL>
**コメント数**: 全 N 件 / 未解決 M 件 / 対応対象 K 件

## 🔴 対応必須 (X件)

### 1. <ファイル>:<行> @<レビュアー>
> <コメント本文の要約>

- **指摘**: 何を問題視しているか
- **対応方針**: 具体的にどう直すか
- **コメントURL**: <url>

### 2. ...

## 🟡 対応推奨 (X件)

（同フォーマット）

## 🔵 要相談 (X件)

### N. <ファイル>:<行> @<レビュアー>
> <要約>

- **論点**: 何を決める必要があるか
- **選択肢**: A案 / B案
- **推奨**: （あなたの見解）
- **コメントURL**: <url>

## ⚪ 対応不要 (X件)

短い理由とともに一覧で。返信案があれば添える。

| # | ファイル:行 | レビュアー | 内容要約 | 対応不要の理由 | 返信案 |
|---|---|---|---|---|---|

## 📌 全体所感

レビュー全体の傾向（例: スタイル指摘が多い / 設計レベルの懸念がある / テスト不足の指摘が集中している）を1〜3行で。
```

### 5. 次のアクション提案

整理結果を提示したあと、ユーザーに以下を聞く（または提案する）:

- 🔴 対応必須の修正に着手するか
- 🔵 要相談のコメントへの返信を一緒に考えるか
- ⚪ 対応不要分への返信＋スレッドクローズを代行するか

ユーザーが「対応必須を直して」と言ったら、別途実装作業に入る。返信や resolve は `gh api` で行えるが、**スレッドの resolve は GraphQL mutation `resolveReviewThread` を使う**。

## エラーハンドリング

- **ghコマンドが未認証**: `gh auth login` を案内
- **PRが特定できない**: 「現在のブランチに紐づく PR がありません。番号を指定してください」
- **コメント0件**: 「未解決のコメントはありません」と簡潔に報告し終了
- **GraphQLレートリミット**: REST フォールバックを案内（resolved判定は落ちる旨も伝える）

## 注意事項

- 分類は **提案** であって決定ではない。最終判断はユーザーが行う前提で書く。
- レビュアーの意図が読み取れないコメントは無理に分類せず「要相談」に置き、原文へのリンクを必ず添える。
- リポジトリのコメントが英語中心の場合、要約は元コメントの言語と日本語の両方を併記してもよい（迷ったら日本語のみ）。
- AIレビュアー（CodeRabbit / Codex / GitHub Copilot review 等）のコメントは個別に件数集計すると傾向が見えやすい。所感セクションに `AIレビュアー: X件 / 人間: Y件` を併記してもよい。
