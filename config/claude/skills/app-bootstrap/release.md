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
- カテゴリ設定(App Store Connect の「アプリ情報」、プライマリ必須) — 手動
- ストア掲載文言・スクリーンショット — 手動(下記5節参照)
- iOS暗号化申告: `app.json` の `ios.infoPlist.ITSAppUsesNonExemptEncryption: false`
  (標準HTTPSのみなら false でよい、`setup.md`で設定済みのはず)
- 提出前チェックの流れ: bundleIdentifier/package設定 → eas.json → EAS Hosted環境変数
  → プライバシーポリシー → レート制限 → 年齢レーティング/スクショ

## 5. ストア新規アプリ作成・掲載情報・スクショ・EAS submit設定 ☁️

claude-in-chromeでブラウザ操作すれば、ここまではクラウドセッションでも完結する
(ダウンロード/認証情報発行を伴う操作はユーザーに確認しながら進めること)。

### 新規アプリ作成

- **Google Play Console**: `console.play.google.com` → 「アプリを作成」。パッケージ名は
  後から変更不可なので `app.json` の `android.package` と厳密に一致させる。無料/有料は
  公開後に無料→有料の変更ができない点に注意。
- **App Store Connect**: `appstoreconnect.apple.com/apps` → 「新規アプリ」。バンドルIDは
  事前に登録済みの App ID から選ぶ(無ければ Certificates, Identifiers & Profiles で先に
  作成)。SKU は好きな一意文字列(bundle id を流用してよい)。
  - フォームの言語/バンドルID の `<select>` は `form_input` で値を設定しても React 側の
    state が更新されないことがある(表示は変わらず送信時にエラーになる)。その場合は
    `javascript_tool` で `HTMLSelectElement.prototype` の native setter 経由で
    `value` をセットしてから `change`/`input` イベントを発火させると確実に反映される。

### 掲載情報(テキスト)

アプリ名・説明・キーワードなどのフォーム入力は、クリック位置がズレると別のフィールドに
文字が入ることがあるので、`find` で正確に要素を特定してから `left_click` → `type` する。
入力後は保存してからスクリーンショットで反映を確認すること(入力した内容が保存されずに
消えていることがある)。

### スクリーンショット・フィーチャーグラフィック

`tools/appstore/` にストア用画像を**アプリの実画面から**自動生成するツールがある
(`npm run shots`)。詳細は `tools/appstore/README.md`。

- **寸法は実際にストアの管理画面が要求してくるサイズを確認してから決める。** Appleの
  「Apple が自動スケールするので最大サイズ1セットだけでよい」という説明は当てにせず、
  App Store Connect の配信ページでスクリーンショットのアップロード欄に実際に表示される
  寸法(例:「iPhone 6.5インチディスプレイ」なら 1242×2688 等)に `tools/appstore/creatives.mjs`
  の `OUTPUTS.appstore` を合わせること。ズレていると「1個以上のスクリーンショットの寸法が
  正しくありません」で保存できない。
- ファイルのアップロードは `computer` でアップロードボタンをクリックしない
  (ネイティブファイルピッカーが開いて操作不能になる)。`find` で `input type=file`
  要素を探し、一度ボタンをクリック→隠れた`input`が出現するのを`find`で再検出→
  `file_upload` にそのrefとローカルパスを渡す、という手順が必要なことがある。

### EAS submit 用の認証情報

**App Store Connect API Key も Google Play サービスアカウント鍵も、通常はアカウント単位
で使い回せる。新規アプリだからといって新規発行は不要。**

- **iOS**: `expo.dev/accounts/<account>/settings/credentials` の
  「App Store Connect API Keys」に既存キーがないか先に確認する。あれば
  そのキー(Team Key、Admin/App Manager権限)は Apple Developer チーム配下の全アプリに
  使える。`.p8` の実ファイルはダウンロード時一回しか取得できないので、無くしていたら
  Apple 側 (Users and Access > Integrations > App Store Connect API) で無効化して
  作り直す。
- **Android**: 同じページの「Google Service Account Keys」に既存の鍵があれば、
  Google Play Console の「ユーザーと権限」でそのサービスアカウント(例:
  `expo-eas@<project>.iam.gserviceaccount.com`)を検索 →「アプリを追加」で今回の
  新規アプリにチェック →「リリース」権限グループの
  **「製品版としてのリリース、デバイスの除外、Play App Signing の使用」**を付与すれば、
  鍵を新規発行しなくてもそのアプリに `eas submit` できるようになる。

`eas.json` の `submit.production` には機密でない情報だけを書く(`.p8`/サービスアカウント
jsonの実体パスはローカルに無くてよい。無ければ `eas submit` 実行時に EAS 側に登録済みの
キーを対話的に選ばせ、一度選べばプロジェクトに紐づいて以後は非対話でも使われる):

```json
"submit": {
  "production": {
    "ios": { "ascAppId": "<App Store Connect の Apple ID(数字)>", "appleTeamId": "<Apple Developer Team ID>" },
    "android": { "track": "production" }
  }
}
```
