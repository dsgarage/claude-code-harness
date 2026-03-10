---
name: rn-build
description: React Native ビルド & テスト
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[path]"
---

# React Native ビルド & テスト

Expo プロジェクトのビルド、型チェック、テストを実行する。

## 実行手順

1. `app.config.ts` が存在するディレクトリを特定する（引数があればそのパス、なければカレントディレクトリ配下を検索）
2. 以下のステップを順番に実行する

### Step 1: 依存関係チェック
```bash
cd <project-dir>
# node_modules が無ければインストール
[ -d node_modules ] || npx expo install
```

### Step 2: TypeScript 型チェック
```bash
npx tsc --noEmit
```
- エラーが出たら型の不整合を報告
- `strict: true` 設定前提で厳密にチェック

### Step 3: Expo Doctor
```bash
npx expo-doctor
```
- SDK バージョンと依存ライブラリの互換性を確認
- 非推奨パッケージや設定の警告を報告

### Step 4: テスト（設定されている場合）
```bash
# Jest が設定されていれば実行
npx jest --passWithNoTests 2>&1
```
- テスト未設定の場合はスキップして報告

### Step 5: Expo 開発サーバー起動確認（オプション）
```bash
# ビルドが通るか確認（サーバーは起動しない）
npx expo export --platform ios --output-dir /tmp/expo-export-check 2>&1
```

### Step 6: 結果サマリー
```
## ビルド結果
- 依存関係: OK / NG
- TypeScript 型チェック: OK / NG (エラーN件)
- Expo Doctor: OK / 警告N件
- テスト: N件パス / 未設定
- エクスポート: OK / NG

### エラー詳細 (あれば)
- [ファイル:行] エラー内容
- 修正案: ...

### 警告詳細 (あれば)
- [ファイル:行] 警告内容
```

## 注意事項
- EAS Build はリモートビルドのため時間がかかる → ローカルチェックを優先
- `EXPO_PUBLIC_API_URL` 環境変数が設定されていない場合、API接続テストは不可
- Android エミュレーターと iOS シミュレーターで API URL の解決方法が異なる
  - Android: `10.0.2.2` / iOS: `localhost`
- `package.json` の `scripts` セクションにカスタムスクリプトがあれば優先使用
