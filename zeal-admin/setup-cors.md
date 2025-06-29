# Firebase Storage CORS設定手順

音楽ファイルのアップロードが失敗する場合、Firebase StorageのCORS設定が必要な可能性があります。

## 設定手順

1. Google Cloud SDK (gcloud) をインストール
   ```bash
   # macOSの場合
   brew install google-cloud-sdk
   ```

2. gcloudで認証
   ```bash
   gcloud auth login
   ```

3. プロジェクトIDを設定
   ```bash
   gcloud config set project zeal-develop
   ```

4. CORS設定を適用
   ```bash
   gsutil cors set cors.json gs://zeal-develop.appspot.com
   ```

## cors.jsonの説明

- `origin`: アクセスを許可するオリジン（開発環境と本番環境のURLを含める）
- `method`: 許可するHTTPメソッド
- `maxAgeSeconds`: プリフライトリクエストのキャッシュ時間
- `responseHeader`: 許可するレスポンスヘッダー

## 確認方法

設定が正しく適用されたか確認するには：
```bash
gsutil cors get gs://zeal-develop.appspot.com
```