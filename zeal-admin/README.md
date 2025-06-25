# ZEAL Admin Panel

ZEALアプリのコンテンツ管理システム

## 機能

- **認証システム**: Firebase Authを使用したemail/passwordログイン
- **コンテンツ管理**: アファメーション、音楽、動画の作成・編集・削除
- **ファイルアップロード**: Firebase Storageを使用した音楽・動画ファイルのアップロード
- **CSVインポート**: アファメーションの一括インポート機能
- **プレビュー機能**: 音楽・動画のブラウザ内プレビュー
- **レスポンシブデザイン**: モバイル対応のダークテーマUI

## セットアップ

### 1. 依存関係のインストール

```bash
cd zeal-admin
npm install
```

### 2. Firebase設定

Firebase CLIで設定を取得済みです：

**開発環境（デフォルト）**:
- `.env.local` - zeal-develop プロジェクト設定済み

**本番環境**:
- `.env.prod` - zeal-product プロジェクト設定済み

**環境切り替え**:
```bash
# 本番環境で起動
cp .env.prod .env.local
npm run dev

# 開発環境に戻す  
cp .env.local.backup .env.local  # 必要に応じて
```

### 3. 開発サーバーの起動

```bash
npm run dev
```

ブラウザで `http://localhost:3000` にアクセス

## ファイル構造

```
zeal-admin/
├── src/app/
│   ├── admin/                 # 管理画面
│   │   ├── page.tsx          # コンテンツ一覧
│   │   ├── affirmations/[id]/ # アファメーション編集
│   │   ├── music/[id]/       # 音楽編集
│   │   └── videos/[id]/      # 動画編集
│   ├── login/                # ログイン画面
│   └── layout.tsx            # ルートレイアウト
├── components/
│   ├── AuthGuard.tsx         # 認証ガード
│   ├── Layout.tsx            # メインレイアウト
│   ├── CSVImport.tsx         # CSVインポート
│   └── MediaPreview.tsx      # メディアプレビュー
└── lib/
    ├── firebase.js           # Firebase設定
    ├── auth-context.tsx      # 認証コンテキスト
    └── types.ts              # TypeScript型定義
```

## 使用方法

### 1. ログイン
- 管理者のemail/passwordでログイン

### 2. コンテンツ管理
- **アファメーション**: テキスト、カテゴリ、タグを設定
- **音楽**: 音楽ファイル、アーティスト、カテゴリ、画像を設定
- **動画**: 動画ファイル、サムネイル、説明、カテゴリを設定

### 3. CSVインポート
- アファメーションタブで「CSV一括インポート」ボタンをクリック
- テンプレートをダウンロードして参考にする
- CSVファイル形式: `text,category,tags,active`

### 4. プレビュー
- 音楽・動画の一覧で「プレビュー」ボタンをクリック

## 注意事項

- Firebase設定（`.env.local`）は実際のプロジェクトのAPIキーを設定してください
- 管理者ユーザーはFirebase Consoleで作成してください
- ファイルアップロードはFirebase Storageの容量制限に注意してください
