# dotfiles
Config files for bash and vim, git

## Usage (mise bootstrap)

```
brew install mise
mise trust
mise bootstrap status   # 現在との差分
mise bootstrap --dry-run
mise bootstrap
```
vim プラグインは vim で `:PlugInstall`。

新マシンでは `mise bootstrap --from github.com/tmatsuo/dotfiles` で一発。

### ディレクトリ構成

ディレクトリ名がそのまま配置先。

| ディレクトリ | 配置先 |
|---|---|
| `home/` | `~` |
| `config/` | `~/.config` (`*.md` は除外) |
| `claude/` | `~/.claude` |

`config/nvim` と `claude/skills` だけはディレクトリごと symlink（中にツールが書き戻すため）。

`~/.config/karabiner/karabiner.json` は `config/karabiner.edn` から goku が生成するので
git 管理しない。過去の未使用プロファイル `Layered` は削除済み
（`git show 6da6fef:config/karabiner/karabiner.json` で取り出せる）。

### Claude Code のスキル

`claude/skills/` は出どころで管理方法が分かれる。`.gitignore` は許可リスト方式で、自作のものだけ git に入る。

| 種類 | 管理方法 |
|---|---|
| 自作 | git 管理。`.gitignore` に `!claude/skills/<名前>/` を足す（足さないと黙って ignore される） |
| skills CLI で入れたもの | `home/.agents/.skill-lock.json`（`~/.agents/.skill-lock.json` の実体）に記録。本体は ignore |
| `synced/` | claude.ai から自動同期。ignore |
| プラグイン | `~/.claude/plugins/` に入るので `claude/skills/` とは無関係 |

skills CLI で追加するときは Claude Code 向けにグローバルで入れる。lock が更新されるのでそれをコミットする。

```
npx skills add <owner/repo> -g -a claude-code -s <スキル名> -y
```

lock から一括で復元するコマンドが無いので、`mise bootstrap` の `post-tools` フックで
lock を読み、`~/.claude/skills/` に無いスキルだけ `skills add` し直している。
新マシンでは bootstrap だけで揃う。

### mise.toml でカバーしていないもの

初回は手で実行する。

- `sudo softwareupdate --install-rosetta`
- `sudo xcodebuild -license accept`
- `sudo sh -c "echo /opt/homebrew/bin/fish >> /etc/shells"` (chsh の前提)
- fish での mise 有効化。`config.fish` が本リポジトリへの symlink なので
  `[bootstrap.mise_shell_activate]` は使わず、必要なら config.fish に直接書く

## Note
- Macの通知が来ない場合はミラーリング時通知設定を確認
