# ZEALアプリ - 課金機能セットアップガイド

## 概要
ZEALアプリのTip機能で使用する課金システムのセットアップ手順を説明します。

## 前提条件
- App Store Connect および Google Play Console への開発者アカウント登録済み
- ZEALアプリが両プラットフォームで登録済み

## 商品設定

### 課金商品リスト
以下の4つの商品を設定する必要があります：

| 商品ID | 金額 | 説明 | 商品タイプ |
|--------|------|------|------------|
| `tip_100` | ¥100 | Small celebration tip | 消費型 |
| `tip_300` | ¥300 | Medium celebration tip | 消費型 |
| `tip_500` | ¥500 | Large celebration tip | 消費型 |
| `tip_1000` | ¥1000 | Premium celebration tip | 消費型 |

## iOS設定 (App Store Connect)

### 1. App Store Connect にログイン
1. [App Store Connect](https://appstoreconnect.apple.com) にアクセス
2. 「マイ App」→ ZEALアプリ を選択

### 2. App内課金設定
1. 左メニューから「機能」→「App内課金」を選択
2. 「管理」ボタンをクリック

### 3. 商品作成
各商品について以下を設定：

#### tip_100
- **タイプ**: 消費型
- **商品ID**: `tip_100`
- **参照名**: Tip 100 Yen
- **価格**: ¥100 (価格帯から選択)
- **表示名**: 小さなお祝い
- **説明**: 夢の実現をお祝いする小さなTip

#### tip_300
- **タイプ**: 消費型
- **商品ID**: `tip_300`
- **参照名**: Tip 300 Yen
- **価格**: ¥300
- **表示名**: 中くらいのお祝い
- **説明**: 夢の実現をお祝いする中くらいのTip

#### tip_500
- **タイプ**: 消費型
- **商品ID**: `tip_500`
- **参照名**: Tip 500 Yen
- **価格**: ¥500
- **表示名**: 大きなお祝い
- **説明**: 夢の実現をお祝いする大きなTip

#### tip_1000
- **タイプ**: 消費型
- **商品ID**: `tip_1000`
- **参照名**: Tip 1000 Yen
- **価格**: ¥1000
- **表示名**: プレミアムお祝い
- **説明**: 夢の実現をお祝いするプレミアムTip

### 4. 各商品の承認申請
1. 各商品の詳細画面で「承認申請」をクリック
2. 審査が完了するまで待機（通常24-48時間）

### 5. テストアカウント設定
1. 「ユーザーとアクセス」→「Sandboxテスター」
2. 「+」ボタンでテストアカウントを作成
3. 実機でテストアカウントでログイン

## Android設定 (Google Play Console)

### 1. Google Play Console にログイン
1. [Google Play Console](https://play.google.com/console) にアクセス
2. ZEALアプリを選択

### 2. 商品設定
1. 左メニューから「収益化」→「商品」→「アプリ内商品」を選択
2. 「商品を作成」をクリック

### 3. 商品作成
各商品について以下を設定：

#### tip_100
- **商品ID**: `tip_100`
- **名前**: 小さなお祝い
- **説明**: 夢の実現をお祝いする小さなTip
- **価格**: ¥100
- **商品タイプ**: 管理対象（消費型）

#### tip_300
- **商品ID**: `tip_300`
- **名前**: 中くらいのお祝い
- **説明**: 夢の実現をお祝いする中くらいのTip
- **価格**: ¥300

#### tip_500
- **商品ID**: `tip_500`
- **名前**: 大きなお祝い
- **説明**: 夢の実現をお祝いする大きなTip
- **価格**: ¥500

#### tip_1000
- **商品ID**: `tip_1000`
- **名前**: プレミアムお祝い
- **説明**: 夢の実現をお祝いするプレミアムTip
- **価格**: ¥1000

### 4. 商品の有効化
1. 各商品の詳細画面で「有効化」をクリック
2. 「保存」をクリック

### 5. テストアカウント設定
1. 「設定」→「ライセンステスト」
2. テスト用Googleアカウントを追加
3. 「内部テスト」または「クローズドテスト」でアプリを配布

## アプリ設定

### 1. 依存関係の追加
既にpubspec.yamlに追加済み：
```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

### 2. iOS権限設定
`ios/Runner/Info.plist` に以下を追加（必要に応じて）：
```xml
<key>NSUserTrackingUsageDescription</key>
<string>This app uses tracking to provide personalized experience</string>
```

### 3. Android権限設定
`android/app/src/main/AndroidManifest.xml` に以下を追加：
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

## テスト手順

### 1. 開発環境でのテスト
```bash
# 依存関係をインストール
flutter pub get

# 開発環境で実行
flutter run -t lib/main_dev.dart
```

### 2. iOS テスト
1. Xcode でプロジェクトを開く
2. 実機でビルド＆実行
3. Sandboxテストアカウントでログイン
4. Tip機能をテスト

### 3. Android テスト
1. Play Console でアプリを内部テストとして配布
2. テストアカウントでPlay Storeからインストール
3. Tip機能をテスト

## 注意事項

### セキュリティ
- 本番環境では必ずサーバーサイドでレシート検証を実装
- 購入情報は暗号化して保存
- Firebase Firestore のセキュリティルールを適切に設定

### 開発時の注意
- Sandboxテストでは実際の課金は発生しない
- 実機でのテストが必要（シミュレーターでは動作しない）
- 商品ID は本番とテストで同じものを使用

### 本番リリース前のチェックリスト
- [ ] 全ての商品が承認済み
- [ ] レシート検証システムの実装
- [ ] エラーハンドリングの確認
- [ ] 実機での動作確認
- [ ] 購入フローのテスト完了
- [ ] Firebase Firestore セキュリティルール設定

## トラブルシューティング

### よくある問題
1. **商品が見つからない**: 商品IDが正しく設定されているか確認
2. **購入できない**: テストアカウントでログインしているか確認
3. **レシート検証エラー**: Firebase Functions が正しく設定されているか確認

### デバッグ方法
```bash
# Flutterアプリのログを確認
flutter logs

# iOS デバイスログを確認
xcrun devicectl list devices
xcrun devicectl device install app --device [DEVICE_ID] [APP_PATH]
```

## サポート
技術的な問題が発生した場合は、以下のドキュメントを参照：
- [Flutter In-App Purchase プラグイン](https://pub.dev/packages/in_app_purchase)
- [Apple In-App Purchase プログラミングガイド](https://developer.apple.com/in-app-purchase/)
- [Google Play Billing ライブラリ](https://developer.android.com/google/play/billing)