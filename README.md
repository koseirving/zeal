# Zeal

Flutter + Firebase モバイルアプリケーション

## 環境構成

- **開発環境**: zeal-develop
- **本番環境**: zeal-product

## セットアップ

1. Flutter SDKのインストール
2. Firebase CLIのインストール
3. 依存関係のインストール:
   ```bash
   flutter pub get
   ```
4. iOS deployment targetが13.0以上に設定済み

## 実行方法

### VSCode
左側のデバッグパネルから環境を選択:
- Flutter (Dev) - 開発環境
- Flutter (Prod) - 本番環境

### コマンドライン

開発環境:
```bash
make dev
# または
flutter run -t lib/main_dev.dart
```

本番環境:
```bash
make prod
# または
flutter run -t lib/main_prod.dart
```

## ビルド

### iOS

#### App Store提出用ビルド
```bash
# 1. クリーンビルド
make clean
make get

# 2. Production環境でビルド（重要：必ずこのコマンドを使用）
make build-prod-ios
# または
flutter build ios -t lib/main_prod.dart --dart-define=ENVIRONMENT=prod

# 3. Xcodeでアーカイブ作成
# - ios/Runner.xcworkspaceを開く
# - Product > Archive
# - App Store Connectへアップロード
```

#### 開発用ビルド
```bash
# 開発環境
make build-dev-ios

# 本番環境（テスト用）
make build-prod-ios
```

### Android
```bash
# 開発環境
make build-dev-android

# 本番環境
make build-prod-android
```

### 重要な注意事項
⚠️ **App Store提出時は必ず`make build-prod-ios`を使用してください**
- デフォルトの`flutter build ios`は開発環境でビルドされます
- Production環境では実際のIn-App Purchaseが有効になります
- 開発環境ではMockモードで動作し、実際の課金処理が行われません

## プロジェクト構造

```
lib/
├── config/
│   ├── app_config.dart      # 環境設定
│   ├── dev/
│   │   └── firebase_options.dart
│   └── prod/
│       └── firebase_options.dart
├── main.dart               # メインアプリ
├── main_dev.dart          # 開発環境エントリーポイント
└── main_prod.dart         # 本番環境エントリーポイント
```

## 機能

### 環境分離
- 開発環境（オレンジ表示）と本番環境（緑表示）で完全分離
- 各環境で異なるFirebaseプロジェクトを使用
- アプリ内で現在の環境が視覚的に確認可能

### Firebase設定
- Firebase Auth（認証）
- Cloud Firestore（データベース）
- Firebase Storage（ストレージ）
- Firebase Analytics（分析）
- Firebase Crashlytics（クラッシュレポート）

### 開発サポート
- VSCode起動設定完備
- Makefileによる簡単コマンド実行
- 環境別ビルドコマンド
- ホットリロード対応
- エラーハンドリング実装