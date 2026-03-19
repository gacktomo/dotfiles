---
description: GitHubのissue状況からタスク進捗を要約してTODOリストを更新する
argument-hint: （省略可）特記事項
---

# GitHub Issue進捗要約 (summarize)

`~/.claude/nippo/tasks.md` の未完了タスクをGitHub issueと照合し、進捗を要約してtasks.mdを更新します。

## 手順

### 1. tasks.md を読み込む

`~/.claude/nippo/tasks.md` を読み込み、以下を把握する：
- 未完了タスク一覧（issue URLがあるものとないもの）
- 完了タスク一覧
- 各タスクのプロジェクト名

### 2. GitHub issueの現在状況を取得する

**未完了タスクのissue状況を確認：**

tasks.mdの未完了タスクに含まれるGitHub issue URL（`https://github.com/...issues/NNN` 形式）を抽出し、各issueの状況を取得：

```bash
gh issue view <issue_url> --json title,state,body,labels,assignees,updatedAt
```

**自分に割り当てられたopen issueを全取得：**

ownerとassigneeは必ず指定する：

```bash
gh search issues --assignee @me --owner Accel-Hack --state open --limit 50 --json title,url,repository,state,updatedAt,labels
```

これにより、tasks.mdに未登録の新規issueも発見できる。

### 3. 状況を分析してタスクを更新する

取得したissue情報を以下のロジックで処理する：

**issueがclosedになっている未完了タスク：**
- `- [ ]` → `- [x]` に変更
- 末尾に `| 完了: YYYY-MM-DD` を追加（issueのclose日付またはupdatedAt）
- 「未完了タスク」セクションから「完了タスク」セクションへ移動

**gh searchで見つかったが tasks.md に未登録のissue：**
- 「未完了タスク」セクションに追加
- 形式：`- [ ] {issueタイトル} ({issue_url}) | プロジェクト: {リポジトリ名} | 追加: YYYY-MM-DD`

**tasks.mdにあるがgh上で見つからないタスク（issue URLなし）：**
- 会話の文脈から判断するか、そのまま維持する

### 4. 進捗サマリーを生成する

各issueのtitle・state・labels・bodyの冒頭から進捗を要約する。issueのbodyが長い場合は冒頭200文字程度を参照し、ラベル（in-progress、review待ちなど）も考慮する。

### 5. 作業ログを追記する

「作業ログ」セクションに以下を追記する：

```markdown
### {YYYY-MM-DD} {HH:MM}

**GitHub Issue 進捗サマリー：**
- {issue名}：{状態}（{簡潔な進捗メモ}）
- {issue名}：{状態}（{簡潔な進捗メモ}）

**完了確認タスク：**
- {issue名}（#{番号}）

**新規追加タスク：**
- {issue名}（#{番号}）

**次のアクション：**
- {最優先のopen issueや次にやること}
```

### 6. tasks.md を更新して結果を表示する

tasks.mdを更新し、以下を表示する：
- 確認したissue数と各issueの現在ステータス
- 完了に更新したタスク一覧
- 新たに追加したタスク一覧（ある場合）
- 残り未完了タスク数
- 次のアクション（最優先issueのタイトルと概要）

## タスク行フォーマット

```
- [ ] {タイトル} ({issue_url}) | プロジェクト: {リポジトリ名} | 追加: YYYY-MM-DD
- [x] {タイトル} ({issue_url}) | プロジェクト: {リポジトリ名} | 追加: YYYY-MM-DD | 完了: YYYY-MM-DD
```

issue URLがないタスクはURLを省略してよい。

## エラーハンドリング

- gh CLIが認証されていない場合：`gh auth status` を確認してユーザーに通知する
- 特定のリポジトリへのアクセス権がない場合：スキップしてその旨を表示する
- ネットワークエラーの場合：取得できたissueのみで処理を進める
