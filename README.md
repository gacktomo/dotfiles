# dotfiles
Config files for bash and vim, git

## Usage
```
./common_setup.sh

# for MacOS
./macos_setup.sh

# for Ubuntu
./ubuntu_setup.sh
```
Install vim plugins at vim command
```
:PlugInstall
```

## Usage (mise bootstrap) — 移行中

`mise.toml` に上記スクリプトの内容を宣言的に書き直したもの。既存スクリプトと並存しており、
どちらを使ってもよい。

```
brew install mise
mise trust
mise bootstrap status   # 現在との差分
mise bootstrap --dry-run
mise bootstrap
```

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

### mise.toml でカバーしていないもの

スクリプト側に残しているので、初回は手で実行する。

- `sudo softwareupdate --install-rosetta`
- `sudo xcodebuild -license accept`
- `sudo sh -c "echo /opt/homebrew/bin/fish >> /etc/shells"` (chsh の前提)
- aerospace (独自 tap の cask で Ruby 3 が要るため Brewfile 側に残置)
- fish での mise 有効化。`config.fish` が本リポジトリへの symlink なので
  `[bootstrap.mise_shell_activate]` は使わず、必要なら config.fish に直接書く

## Note
- Macの通知が来ない場合はミラーリング時通知設定を確認
