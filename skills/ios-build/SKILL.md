---
name: ios-build
description: iOS ビルド & テスト
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[path]"
---

# iOS ビルド & テスト

XcodeGen プロジェクトのビルドとテストを実行する。

## 実行手順

1. `project.yml` が存在するディレクトリを特定する（引数があればそのパス、なければカレントディレクトリ配下を検索）
2. 以下のステップを順番に実行する

### Step 1: プロジェクト生成
```bash
cd <project-dir>
xcodegen generate
```
成功を確認してから次へ進む。

### Step 2: シミュレータービルド
```bash
xcodebuild -project *.xcodeproj \
  -scheme <scheme-name> \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -quiet \
  build 2>&1
```
- scheme 名は `project.yml` の `targets` セクションから取得
- エラーが出たら内容を解析し、修正案を提示する
- **SourceKit の `unavailable in macOS` 警告は無視**（iOS 専用 API の偽陽性）
- Sendable 関連の警告は報告するが、修正は任意

### Step 3: ユニットテスト
```bash
xcodebuild -project *.xcodeproj \
  -scheme <scheme-name> \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test 2>&1
```
- テスト結果をパースし、pass/fail を報告
- 失敗したテストがあれば、テストコードとテスト対象コードを読んで原因を分析

### Step 4: 結果サマリー
```
## ビルド結果
- プロジェクト生成: OK / NG
- シミュレータービルド: OK / NG (警告N件)
- テスト: N件中M件パス / N件失敗

### エラー詳細 (あれば)
- [ファイル:行] エラー内容
- 修正案: ...

### 警告詳細 (あれば)
- [ファイル:行] 警告内容
```

## 注意事項
- `Makefile` がある場合は `make build` / `make test` を優先的に使用
- ビルドエラーの大半は以下に起因する:
  1. `#if targetEnvironment(simulator)` ガードの不足
  2. `@Observable` と `#if` の非互換
  3. `import` 文の `#if` ガード漏れ
  4. `@available` チェックの不足
