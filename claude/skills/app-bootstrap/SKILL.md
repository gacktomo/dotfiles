---
name: app-bootstrap
description: 新しいアプリのアイデアを Expo(React Native) + Cloudflare Workers + EAS + AdMob + Firebase の構成で「思いつき→ストア配信」まで進めるための手順書。新規プロジェクトの立ち上げ、バックエンドAPI、ネイティブビルド、広告/Analytics組み込み、OTA配信、ストア提出をするときに使う。クラウド実行(ブラウザ操作なし)を前提にした代替手段も含む。umigameアプリでの実運用から得た地雷情報がベース。
---

# Expo + Cloudflare Workers アプリ 立ち上げ〜配信 手順書

2フェーズに分かれている。まず今どちらのフェーズかを判断してから該当ファイルを読むこと。

- **`setup.md`**: 思いつき→動くものを作って確認できるまで。新規プロジェクト立ち上げ、
  Cloudflare Workersバックエンド、EAS初期設定、検証ルーチン、Web版デプロイ、OTA配信、
  実機でのネイティブビルド確認。「まずさっと作って動かしたい」はここ。
- **`release.md`**: `setup.md`で動くものが確認できた後、収益化・計測・ストア提出に
  進む段階。AdMob、Firebase(Analytics/Crashlytics)、それらを組み込んだ後の
  ネイティブビルド特有の落とし穴、ストア提出チェックリスト。

各手順に ☁️(クラウドのClaude Codeでも完結する) / 💻(ローカルセッション or
ユーザー手動が要る) が付いている。自分がどちらの環境で動いているかを把握してから進むこと。
