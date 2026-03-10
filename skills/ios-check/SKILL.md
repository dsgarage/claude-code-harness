---
name: ios-check
description: iOS コードのエラーパターン検出
allowed-tools: Read, Grep, Glob
argument-hint: "[path]"
---

# iOS コードチェック

iOS/Swift/SwiftUI のコードを検査し、よくあるエラーパターンを検出・修正する。

## 実行手順

1. 対象ファイルまたはディレクトリを特定する（引数があればそのパス、なければカレントディレクトリ）
2. 以下のチェック項目を順番に検査する
3. 問題を発見したら、ファイルパス・行番号・問題内容・修正案を報告する

## チェック項目

### 1. @Observable と #if の非互換性チェック
- `@Observable` マクロが付いたクラス内に `#if !targetEnvironment(simulator)` ブロックがあるか検索
- ブロック内にシミュレーター非対応の型（`ObjectCaptureSession`, `ARSession`, `ARView`, `ARMeshAnchor`, `PhotogrammetrySession` 等）があれば **エラー** として報告
- 修正案: `ObservableObject` + `@Published` に変更、または型消去パターン（`private var _session: Any?`）を提案

### 2. #if targetEnvironment(simulator) ガード漏れチェック
- ARKit / RealityKit のシミュレーター非対応 API が `#if` ガードなしで使用されていないか検査
- 対象の型: `ARSession`, `ARView`, `ARMeshAnchor`, `ARWorldTrackingConfiguration`, `ObjectCaptureSession`, `ObjectCaptureView`, `PhotogrammetrySession`
- import 文も含めてチェック（`import ARKit`, `import RealityKit` は `#if !targetEnvironment(simulator)` で囲む）

### 3. @available チェック
- iOS 17+ の API（`@Observable`, `ObjectCaptureSession`, `NavigationStack` 等）が `@available(iOS 17.0, *)` または `if #available(iOS 17.0, *)` なしで使用されていないか検査

### 4. SwiftUI データフロー整合性
- `@Observable` クラスが `@StateObject` で参照されていないか（正しくは `@State` または `@Environment`）
- `ObservableObject` クラスが `@Environment` で参照されていないか（正しくは `@StateObject` または `@ObservedObject`）

### 5. PhotogrammetrySession 品質設定
- `.reduced` がハードコードされていないか
- ユーザーの品質選択が適切にマッピングされているか

### 6. LiDAR スキャン範囲
- `BoundingBox` がハードコードで極端に小さくないか（±0.1m 以下は警告）
- クリップ処理が原点基準で固定されていないか

### 7. XcodeGen 設定チェック
- `project.yml` が存在する場合、deployment target、フレームワーク設定を確認
- Info.plist のパーミッション設定（カメラ等）の漏れチェック

## 出力フォーマット

```
## チェック結果

### エラー (修正必須)
- [ファイル:行] 問題の説明 → 修正案

### 警告 (推奨修正)
- [ファイル:行] 問題の説明 → 修正案

### OK
- チェック項目名: 問題なし
```
