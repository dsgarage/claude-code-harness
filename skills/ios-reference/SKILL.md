---
name: ios-reference
description: iOS ドキュメントリファレンス
allowed-tools: Read, WebFetch, WebSearch
argument-hint: "<topic>"
---

# iOS ドキュメントリファレンス

Apple 公式ドキュメントの URL を参照し、指定されたトピックの情報を提供する。

## 実行手順

1. 引数からトピック（API名、フレームワーク名、概念名）を特定する
2. 以下のリファレンス表から該当する URL を探す
3. WebFetch で該当ドキュメントを取得し、要約・使用例を提示する
4. 関連する API や注意事項があれば併せて報告する

## リファレンス URL マップ

### Swift 言語
- swift, swift-lang → https://developer.apple.com/documentation/swift
- swift-book → https://docs.swift.org/swift-book/documentation/the-swift-programming-language/
- concurrency, async, await, actor → https://developer.apple.com/documentation/swift/concurrency
- macro, macros → https://developer.apple.com/documentation/swift/macros

### SwiftUI
- swiftui → https://developer.apple.com/documentation/swiftui
- view → https://developer.apple.com/documentation/swiftui/view
- state → https://developer.apple.com/documentation/swiftui/state
- binding → https://developer.apple.com/documentation/swiftui/binding
- observable → https://developer.apple.com/documentation/Observation/Observable()
- observation → https://developer.apple.com/documentation/Observation
- environment → https://developer.apple.com/documentation/swiftui/environment
- navigationstack → https://developer.apple.com/documentation/SwiftUI/NavigationStack
- navigationsplitview → https://developer.apple.com/documentation/swiftui/navigationsplitview
- uiviewrepresentable → https://developer.apple.com/documentation/swiftui/uiviewrepresentable
- layout → https://developer.apple.com/documentation/swiftui/layout-fundamentals
- stateobject → https://developer.apple.com/documentation/swiftui/stateobject
- observedobject → https://developer.apple.com/documentation/swiftui/observedobject

### ARKit / RealityKit
- arkit → https://developer.apple.com/documentation/arkit
- realitykit → https://developer.apple.com/documentation/realitykit/
- objectcapture → https://developer.apple.com/documentation/realitykit/realitykit-object-capture/
- objectcapturesession → https://developer.apple.com/documentation/realitykit/objectcapturesession
- objectcaptureview → https://developer.apple.com/documentation/realitykit/objectcaptureview
- photogrammetrysession → https://developer.apple.com/documentation/realitykit/photogrammetrysession
- arsession → https://developer.apple.com/documentation/arkit/arsession
- arview → https://developer.apple.com/documentation/realitykit/arview

### その他フレームワーク
- modelio → https://developer.apple.com/documentation/ModelIO
- scenekit → https://developer.apple.com/documentation/scenekit/
- avfoundation → https://developer.apple.com/documentation/avfoundation
- metal → https://developer.apple.com/documentation/metal
- metalkit → https://developer.apple.com/documentation/metalkit
- accelerate → https://developer.apple.com/documentation/accelerate
- xctest → https://developer.apple.com/documentation/xctest
- swift-testing, testing → https://developer.apple.com/documentation/testing

### Xcode
- build-settings → https://developer.apple.com/documentation/xcode/build-settings-reference
- instruments → https://developer.apple.com/tutorials/instruments
- spm, swift-packages → https://developer.apple.com/documentation/xcode/swift-packages

### ガイドライン
- hig → https://developer.apple.com/design/human-interface-guidelines
- hig-ios → https://developer.apple.com/design/human-interface-guidelines/designing-for-ios
- app-review → https://developer.apple.com/app-store/review/guidelines/
- release-notes → https://developer.apple.com/documentation/ios-ipados-release-notes

### ツール
- xcodegen → https://github.com/yonaskolb/XcodeGen
- xcodegen-spec → https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md

## 出力フォーマット

```
## [トピック名] リファレンス

**ドキュメント URL:** [URL]

### 概要
[ドキュメントから取得した概要]

### 主な API / 使い方
[コード例やAPI一覧]

### 注意事項
[プロジェクトに関連する注意点]

### 関連リンク
- [関連ドキュメント名](URL)
```

## トピックが見つからない場合
- `https://developer.apple.com/documentation/<トピック名>` を試行
- WebSearch で `site:developer.apple.com <トピック名>` を検索
- 見つかった URL を WebFetch で取得して要約
