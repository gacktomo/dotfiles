# Phase 2: リリース(広告/計測/ストア提出)

`setup.md` で動くものが確認できた後、収益化・計測・ストア配信に進む段階の手順。
ここから追加するネイティブモジュール(AdMob, Firebase)は `setup.md` 7節の
ネイティブビルド手順を再度使うが、この組み合わせ特有の落とし穴があるので
先に読むこと。

## 1. AdMob ☁️不可・💻のみ

**AdMobにはCLI/MCP/公式APIによるアプリ・広告ユニット作成手段が存在しない。**
ブラウザ操作(claude-in-chrome)か、ユーザー本人による手動作業が必須。

1. まず**既存のAdMobアプリが登録済みでないか必ず確認する**(新規作成前に確認せず
   進めかけて過去に止められたことがある)
2. https://apps.admob.com → 対象アプリ → アプリの設定 → App ID を確認
3. 広告ユニット(インタースティシャル/バナー等、要件に応じて)を作成 → IDを教えてもらう
4. `app.json` の `react-native-google-mobile-ads` plugin に App ID、コード側に
   広告ユニットIDを設定

claude-in-chromeが使える場合でも、AdMob/Firebaseコンソールは仮想スクロールテーブルや
モーダルが自動操作ツールと相性が悪いことが多い。2〜3回試して開かなければ、粘らず
ユーザーに直接URLと手順を渡して手動でやってもらう方が早い。

## 2. Firebase(Analytics/Crashlytics)セットアップ ☁️

Firebase MCP(`mcp__plugin_firebase_firebase__*`)を使う。ブラウザ操作不要、
URLを踏んでユーザー自身がGoogleアカウントでログイン→認証コードを貼り付けてもらう
方式なので**クラウドセッションでも完結する**。未導入なら `/plugin` でユーザーに
インストールを依頼する。

1. `firebase_login` → 表示されるURLとセッションID(先頭5文字)をユーザーに送る
   - フィッシング対策の一致確認をユーザーにさせること(勝手に進めない)
2. ログイン後の認証コードを受け取って渡す
3. `firebase_list_projects` / なければ `firebase_create_project`
4. `firebase_create_app` でiOS/Androidを登録(bundle id / package name を指定)
5. `firebase_get_sdk_config` で設定を取得し、`GoogleService-Info.plist` /
   `google-services.json` としてリポジトリ直下に保存(秘密情報ではないので普通にコミットする)
6. `app.json` の `ios.googleServicesFile` / `android.googleServicesFile` にパスを設定
7. 必要なFirebaseパッケージを `npx expo install` → config pluginが自動で
   `app.json` に追記される

## 3. AdMob + Firebase を組み込んだ後のネイティブビルド

`setup.md` 7節の手順でビルドするが、この組み合わせ特有の落とし穴が2つある。

### 落とし穴1: google-mobile-ads + react-native-firebase の併用

`react-native-google-mobile-ads` のドキュメントは firebase v15+ 併用時に
`use_frameworks! :linkage => :static` を推奨しているが、これは**古い情報**。
`react-native-firebase` v23+ は Firebase iOS SDK を Swift Package Manager 経由で
解決するようになっており、static linkage だと重複シンボルでビルドが落ちる。
正しくは `dynamic`:

```json
["expo-build-properties", { "ios": { "useFrameworks": "dynamic" } }]
```

### 落とし穴2: Crashlyticsのシンボルアップロードスクリプト

`@react-native-firebase/crashlytics` のビルドフェーズスクリプトは `ios/` 直下に
`GoogleService-Info.plist` があることを期待するが、Expoの標準config pluginは
`ios/<AppName>/` 配下にしか置かない。config plugin(`withDangerousMod`)で
`ios/` 直下にもコピーするひと手間が要る。

どちらも、ビルドが失敗したら推測で直さず、署名付きログURLをfetchして`[!]`行を
探して原因を特定してから直すこと。

## 4. ストア提出まわり(コード外・要確認事項) 💻

- プライバシーポリシーページを作って公開する(広告/Analytics/第三者送信があるなら必須)。
  内容を変えたら追記すること
- 年齢レーティング質問票(App Store Connect / Play Console) — 手動
- ストア掲載文言・スクリーンショット — 手動
- iOS暗号化申告: `app.json` の `ios.infoPlist.ITSAppUsesNonExemptEncryption: false`
  (標準HTTPSのみなら false でよい、`setup.md`で設定済みのはず)
- 提出前チェックの流れ: bundleIdentifier/package設定 → eas.json → EAS Hosted環境変数
  → プライバシーポリシー → レート制限 → 年齢レーティング/スクショ
