---
name: rn-reference
description: React Native ドキュメントリファレンス
allowed-tools: Read, WebFetch, WebSearch
argument-hint: "<topic>"
---

# React Native ドキュメントリファレンス

React Native / Expo / 関連ライブラリの公式ドキュメントを参照し、指定トピックの情報を提供する。

## 実行手順

1. 引数からトピック（API名、コンポーネント名、概念名）を特定する
2. 以下のリファレンス表から該当する URL を探す
3. WebFetch で該当ドキュメントを取得し、要約・使用例を提示する
4. 関連する API や注意事項があれば併せて報告する

## リファレンス URL マップ

### React Native コア
- react-native, rn → https://reactnative.dev/docs/getting-started
- components → https://reactnative.dev/docs/components-and-apis
- flatlist → https://reactnative.dev/docs/flatlist
- scrollview → https://reactnative.dev/docs/scrollview
- view → https://reactnative.dev/docs/view
- text → https://reactnative.dev/docs/text
- image → https://reactnative.dev/docs/image
- textinput → https://reactnative.dev/docs/textinput
- touchableopacity → https://reactnative.dev/docs/touchableopacity
- pressable → https://reactnative.dev/docs/pressable
- modal → https://reactnative.dev/docs/modal
- alert → https://reactnative.dev/docs/alert
- stylesheet → https://reactnative.dev/docs/stylesheet
- dimensions → https://reactnative.dev/docs/dimensions
- platform → https://reactnative.dev/docs/platform
- linking → https://reactnative.dev/docs/linking
- performance → https://reactnative.dev/docs/performance
- flatlist-optimization → https://reactnative.dev/docs/optimizing-flatlist-configuration
- typescript → https://reactnative.dev/docs/typescript
- new-architecture → https://reactnative.dev/architecture/landing-page
- hermes → https://reactnative.dev/docs/hermes
- turbomodules → https://reactnative.dev/docs/turbo-native-modules-introduction

### Expo
- expo → https://docs.expo.dev/
- expo-sdk → https://docs.expo.dev/versions/latest/
- expo-router, router → https://docs.expo.dev/router/introduction/
- router-routing → https://docs.expo.dev/router/basics/notation/
- router-layout → https://docs.expo.dev/router/basics/layout/
- router-auth → https://docs.expo.dev/router/advanced/authentication/
- app-config → https://docs.expo.dev/versions/latest/config/app/
- config-plugins → https://docs.expo.dev/config-plugins/introduction/
- expo-modules → https://docs.expo.dev/modules/overview/
- expo-image → https://docs.expo.dev/versions/latest/sdk/image/
- expo-gl → https://docs.expo.dev/versions/latest/sdk/gl-view/
- expo-constants → https://docs.expo.dev/versions/latest/sdk/constants/
- expo-linking → https://docs.expo.dev/versions/latest/sdk/linking/
- dev-builds → https://docs.expo.dev/develop/development-builds/introduction/

### EAS
- eas → https://docs.expo.dev/eas/
- eas-build → https://docs.expo.dev/build/introduction/
- eas-submit → https://docs.expo.dev/submit/introduction/
- eas-update → https://docs.expo.dev/eas-update/introduction/
- submit-ios → https://docs.expo.dev/submit/ios/

### 状態管理
- zustand → https://zustand.docs.pmnd.rs/
- zustand-persist → https://docs.pmnd.rs/zustand/integrations/persisting-store-data
- tanstack-query, react-query → https://tanstack.com/query/latest
- usequery → https://tanstack.com/query/latest/docs/framework/react/reference/useQuery
- context → https://react.dev/reference/react/createContext
- usecontext → https://react.dev/reference/react/useContext

### UI / アニメーション
- reanimated → https://docs.swmansion.com/react-native-reanimated/
- gesture-handler → https://docs.swmansion.com/react-native-gesture-handler/
- nativewind → https://www.nativewind.dev/
- paper → https://callstack.github.io/react-native-paper/
- tamagui → https://tamagui.dev/

### 認証・ストレージ
- asyncstorage → https://docs.expo.dev/versions/latest/sdk/async-storage/
- securestore → https://docs.expo.dev/versions/latest/sdk/securestore/
- authsession → https://docs.expo.dev/versions/latest/sdk/auth-session/

### 3D / GL
- three, threejs → https://threejs.org/docs/
- r3f, react-three-fiber → https://r3f.docs.pmnd.rs/
- expo-three → https://github.com/expo/expo-three

### テスト
- jest → https://jestjs.io/docs/getting-started
- jest-rn → https://jestjs.io/docs/tutorial-react-native
- testing-library → https://callstack.github.io/react-native-testing-library/
- detox → https://wix.github.io/Detox/
- expo-test → https://docs.expo.dev/develop/unit-testing/

### 決済
- stripe-rn → https://github.com/stripe/stripe-react-native
- stripe → https://docs.stripe.com/payments/accept-a-payment?platform=react-native

### デバッグ
- devtools → https://reactnative.dev/docs/react-native-devtools
- debugging → https://reactnative.dev/docs/next/debugging
- expo-debug → https://docs.expo.dev/debugging/tools/

### React コア
- react → https://react.dev/
- usestate → https://react.dev/reference/react/useState
- useeffect → https://react.dev/reference/react/useEffect
- usememo → https://react.dev/reference/react/useMemo
- usecallback → https://react.dev/reference/react/useCallback
- useref → https://react.dev/reference/react/useRef

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
- `https://reactnative.dev/docs/<トピック名>` を試行
- `https://docs.expo.dev/versions/latest/sdk/<トピック名>/` を試行
- WebSearch で `site:reactnative.dev OR site:docs.expo.dev <トピック名>` を検索
- 見つかった URL を WebFetch で取得して要約
