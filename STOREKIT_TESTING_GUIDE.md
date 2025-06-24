# StoreKit テスト課金ガイド

## 概要
実際のApp Store課金をシミュレートしてテストする方法を説明します。

## iOS StoreKit Configuration File 設定方法

### 1. Xcodeでプロジェクトを開く
```bash
open ios/Runner.xcworkspace
```

### 2. StoreKit Configuration Fileを追加
1. **Runner** ターゲットを選択
2. **Signing & Capabilities** タブを開く
3. **+ Capability** をクリック
4. **StoreKit Testing** を追加

### 3. Configuration.storekitファイルを設定
すでに`ios/Runner/Configuration.storekit`を作成済みです。
Xcodeで開いて確認してください。

### 4. スキーム設定
1. Xcode上部の**スキーム**をクリック（Runner > Device）
2. **Edit Scheme...** を選択
3. **Run** → **Options** タブ
4. **StoreKit Configuration** で `Configuration.storekit` を選択

### 5. テスト実行
```bash
flutter run -t lib/main_dev.dart
```

## テスト方法

### 成功テスト
1. Tipボタンをタップ
2. 金額を選択（¥100, ¥300, ¥500, ¥1000）
3. 「Celebrate ¥XXX」をタップ
4. Touch ID/Face ID認証（シミュレータでは自動承認）
5. 購入成功メッセージ確認

### エラーテスト
StoreKit Configurationで以下のテストが可能：
- **購入失敗**: Configuration内で失敗設定
- **ネットワークエラー**: 機内モードでテスト
- **キャンセル**: 認証画面でキャンセル

## Android テスト課金設定

### 1. Google Play Console設定
1. アプリを内部テストトラックにアップロード
2. テスターグループを作成
3. テスト用Googleアカウントを追加

### 2. 商品設定
Google Play Consoleで以下の商品を作成：
- `tip_100` - ¥100
- `tip_300` - ¥300
- `tip_500` - ¥500
- `tip_1000` - ¥1000

### 3. テスト実行
```bash
flutter run -t lib/main_dev.dart
```

## トラブルシューティング

### iOS
**商品が見つからない場合**
1. StoreKit Configurationが正しく選択されているか確認
2. Product IDが一致しているか確認
3. Xcodeでクリーンビルド: Product → Clean Build Folder

**認証が表示されない場合**
- シミュレータ設定でTouch ID/Face IDを有効化

### Android
**テスト購入できない場合**
1. Google Playストアにテストアカウントでログイン
2. 内部テストに参加済みか確認
3. アプリのバージョンコードが一致しているか確認

## 本番との違い

| 項目 | テスト環境 | 本番環境 |
|------|-----------|----------|
| 課金 | 実際の請求なし | 実際に請求 |
| 商品 | ローカル設定 | App Store/Play Store |
| レシート | テスト用 | 本番用 |
| 検証 | 簡易検証 | 厳密な検証必要 |

## 開発フロー

1. **初期開発**: モックモード
2. **機能テスト**: StoreKit Configuration
3. **統合テスト**: Sandboxアカウント
4. **本番準備**: TestFlight/内部テスト
5. **リリース**: 本番環境

これで、実際の課金フローをテストできます！