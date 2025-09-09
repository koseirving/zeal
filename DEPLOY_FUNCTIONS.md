# Firebase Functions デプロイ手順

## 前提条件

1. Firebase CLIがインストールされていること
2. Firebaseにログインしていること (`firebase login`)
3. プロジェクトが正しく設定されていること

## デプロイ手順

### 1. Functions ディレクトリに移動

```bash
cd functions
```

### 2. 依存関係をインストール

```bash
npm install
```

### 3. TypeScriptをビルド

```bash
npm run build
```

### 4. (オプション) App Store Shared Secret を設定

App Store Connectから共有シークレットを取得し、Firebase環境変数に設定：

```bash
firebase functions:config:set appstore.shared_secret="YOUR_SHARED_SECRET_HERE"
```

**注意:** 共有シークレットはオプションですが、セキュリティ強化のため推奨されます。

**App Store Shared Secret の取得方法:**
1. App Store Connect にログイン
2. My Apps > Zeal を選択
3. App Information > App-Specific Shared Secret
4. Generate（まだ生成していない場合）
5. 生成されたシークレットをコピー

### 5. Functions をデプロイ

```bash
firebase deploy --only functions --project zeal-product
```

または、npm scriptを使用：

```bash
npm run deploy
```

### 6. デプロイの確認

デプロイが成功したら、以下のようなメッセージが表示されます：

```
✔  functions[verifyReceipt(us-central1)]: Successful create operation.
✔  functions[healthCheck(us-central1)]: Successful create operation.
```

### 7. ヘルスチェック

デプロイ後、ヘルスチェックエンドポイントで動作確認：

```bash
curl https://us-central1-zeal-product.cloudfunctions.net/healthCheck
```

## トラブルシューティング

### デプロイが失敗する場合

1. **認証エラー**
   ```bash
   firebase login --reauth
   ```

2. **プロジェクトが正しくない**
   ```bash
   firebase use zeal-product
   ```

3. **ビルドエラー**
   ```bash
   npm run build
   ```
   エラーメッセージを確認し、TypeScriptエラーを修正

### ログの確認

Functions のログを確認：

```bash
firebase functions:log --project zeal-product
```

特定の関数のログのみ：

```bash
firebase functions:log --only verifyReceipt --project zeal-product
```

## 本番環境での注意事項

1. **レシート検証の動作確認**
   - TestFlightでアプリをテスト
   - 購入フローを実行
   - Firebase Consoleでログを確認

2. **Firestore のルール**
   - `verified_purchases` コレクションへの書き込み権限を確認
   - Functions のサービスアカウントに適切な権限があることを確認

3. **監視**
   - Firebase Console > Functions でエラー率を監視
   - アラートを設定してエラーを早期発見

## App Store審査対応

この実装により、以下のApp Store要件を満たします：

1. ✅ サーバー側でのレシート検証
2. ✅ 本番/Sandbox環境の自動切り替え
3. ✅ 検証結果のログ記録
4. ✅ セキュアな購入フロー

審査提出前に必ずTestFlightで動作確認を行ってください。