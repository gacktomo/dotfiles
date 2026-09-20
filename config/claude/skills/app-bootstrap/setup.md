# Phase 1: セットアップ(思いつき→動くものを確認できるまで)

新しいアプリを思いついてから、Web版が公開され、実機(ネイティブビルド)でも
動作確認できる状態にするまでの手順。広告/Analytics/ストア提出は`release.md`へ。

各手順に ☁️(クラウドのClaude Codeでも完結する) / 💻(ローカルセッション or
ユーザー手動が要る) を付けている。まず自分がどちらの環境で動いているかを
把握してから進むこと。

## 0. このスタックの構成

- **フロント**: Expo(Expo Router, TypeScript)。Web/iOS/Androidを1コードベースで。
- **バックエンド**: Cloudflare Workers(Hono)。秘密情報はWorkers Secretsか`.dev.vars`(ローカル)。
- **配信**: Web = Cloudflare Workers Builds(GitHub連携、`git push`で自動デプロイ)。
  ネイティブ = EAS Build(ネイティブバイナリ) + EAS Update(OTA、JSのみの変更)。

小さく作って早く確認するのが目的なので、この構成から外れる提案(独自CI等)は
明確な理由がない限りしない。

## 1. 新規プロジェクトの立ち上げ ☁️

```
npx create-expo-app@latest <app-name> --template default
cd <app-name>
npx expo install expo-router
```

- パッケージ名/バンドルIDは最初に決める(後から変えると証明書・AdMob・Firebaseの登録が
  全部やり直しになるので、`release.md`に進む前に確定させておく)。
  例: `com.<owner>.<appname>`
- バックエンドが要るなら `server/` ディレクトリに Hono + `wrangler.jsonc` を用意し、
  クライアントは `EXPO_PUBLIC_API_BASE_URL` 経由で叩く(後述の理由でこの環境変数名に統一)。

## 2. バックエンド(Cloudflare Workers)の鉄則 ☁️

- **本番デプロイは `git push` 経由のみにする。** Cloudflare Workers を
  GitHub連携(Workers Builds)で `main` push検知 → build → deploy させる。
  `wrangler deploy` を手元やCLIから直接叩くと、Workers Builds側とは**別の環境**
  (シークレット未設定の場合が多い)にデプロイされて本番に反映されない。
  過去に実際にこれで1日ハマった。→ 変更は必ずコミットしてpushすること。
- **`main` は複数worktreeから同時に触られている可能性がある。** push前に必ず
  `git fetch origin && git log origin/main..HEAD` でズレを確認し、必要ならrebase。
- **レート制限は自作しない。** Cloudflare Workers のネイティブ Rate Limiting
  binding(`wrangler.jsonc` の `[[unsafe.bindings]]` type `ratelimit`)を使う。
  公開APIを晒す前に必ず入れる(無制限だと外部LLM API等のコストが青天井になる)。
- 秘密情報を使うロジックの妥当性検証や、LLM judgeでのコンテンツ採点のような
  開発用スクリプトは `node script.ts` で直接動かす(Node単体のTS型剥がし実行)。
  追加パッケージ(ts-node等)は不要。ただしNodeの型剥がしはパラメータプロパティ
  (`constructor(private x: string)`)等の一部TS構文を消せないので、
  そういうクラスがあると動かない → 明示代入に書き換える(挙動は変わらない)。

## 3. EAS / ネイティブの初期設定 ☁️

```
npx eas login
npx eas build:configure   # eas.json 生成(development/preview/production)
npx eas update:configure  # OTA用の app.json(updates.url等) + eas.json(channel)
```

- `app.json` に `ios.bundleIdentifier` / `android.package` / `ios.buildNumber`
  (production profileで`autoIncrement: true`にすれば以降は手動管理不要)。
- `ios.infoPlist.ITSAppUsesNonExemptEncryption: false`(標準HTTPSのみなら)。
- **`EXPO_PUBLIC_API_BASE_URL` は EAS Hosted 環境変数(`eas env:create`)に置く。**
  `eas.json` の `build.<profile>.env` は `eas build` にしか効かず、`eas update` では
  読まれない。これを eas.json 側だけに置くと、OTA配信のたびにネイティブアプリが
  `localhost` にフォールバックする(実際に起きた)。preview/production 両方に
  `eas env:create` で登録し、eas.json 側の `env` は消しておく。
  値には**パスの末尾を含めない**(クライアント側で`/api/xxx`を継ぎ足す前提なら
  オリジンだけを渡す。`/api`を含めると二重パスになる)。

## 4. コード変更の検証 ☁️

変更のたびに(pushする前に)必ず:

```
npm run typecheck
npx eslint .
npm run build   # expo export --platform web。ネイティブ専用importが壊れていないか確認
```

`react-native-*` 系のネイティブ専用importを使うファイルは `.web.ts` でプラットフォーム
分岐したスタブを用意し、`npm run build` が壊れないことを確認する。

## 5. Web版デプロイ ☁️

```
git add -A && git commit -m "..." && git push origin <branch>:main
```

数十秒待つと本番ドメインに自動反映される。確認は:

```
until curl -s https://<production-domain>/ | grep -q "<期待する文字列>"; do sleep 15; done
```

## 6. OTA配信(JSのみの変更) ☁️

```
npx eas update --branch preview --environment preview --non-interactive --message "..."
npx eas update --branch production --environment production --non-interactive --message "..."
```

反映は**アプリを完全終了して2回開き直す**必要がある(1回目はバックグラウンドDLのみ)。
ユーザーに確認してもらう時は必ずこれを伝える。

**ネイティブモジュールを追加した回はOTAでは届かない。** 既存バイナリに無い型を
呼びに行ってクラッシュする → 7節のネイティブビルドが必要。

## 7. ネイティブビルド(実機で動作確認) ☁️(2回目以降)/ 💻(iOS初回のみ)

Android は初回から非対話で通る。iOSは初回だけ証明書発行にApple ID対話ログインが要る
(ローカルの実ターミナルで1回 `eas build --profile preview --platform ios` を
インタラクティブモードで走らせておく)。**一度credentialsがEAS側に登録されれば、
以降はクラウドからでも非対話で通る。**

```
npx eas build --profile preview --platform android --non-interactive --no-wait
npx eas build --profile preview --platform ios --non-interactive --no-wait
```

完了待ちは `sleep` 直書きではなく until-loop で:

```
until npx eas build:view <BUILD_ID> --json 2>/dev/null | grep -qE '"status":\s*"(FINISHED|ERRORED|CANCELED)"'; do sleep 30; done
npx eas build:view <BUILD_ID> --json | grep '"status"'
```

完了したら `https://expo.dev/accounts/<account>/projects/<project>/builds/<id>` を
実機のSafari/Chromeで開けばインストールできる(登録済みデバイスのみ。新しい実機は
`eas device:create` の登録が必要 — ユーザーが自分の端末でQR/URLを開く必要があるので💻)。

ビルドが失敗したら推測で直さず、まず署名付きログURLをfetchして`[!]`行(CocoaPods等の
致命的エラー)を探す。ここまでで「動くものが手元で確認できる」状態。広告/Analytics/
ストア提出は `release.md` へ。
