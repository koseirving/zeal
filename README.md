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
```bash
# 開発環境
make build-dev-ios

# 本番環境
make build-prod-ios
```

### Android
```bash
# 開発環境
make build-dev-android

# 本番環境
make build-prod-android
```

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