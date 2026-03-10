# Skills 作成・管理ガイド

## Skills とは？

Claude Code の **Skills** は、スラッシュコマンド（`/ios-build` など）で呼び出せる **定型タスクテンプレート**。

エージェントに毎回同じ手順を説明する代わりに、SKILL.md に手順を書いておけば：
- `/ios-build` で常に同じ品質のビルド手順が実行される
- 手順の漏れがなくなる
- チームで共有できる

## ファイル構造

```
skills/
└── <skill-name>/
    └── SKILL.md     ← スキル定義ファイル
```

## SKILL.md の書き方

### フロントマター（YAML ヘッダー）

```yaml
---
name: ios-build                          # スキル名（スラッシュコマンド名）
description: iOS ビルド & テスト           # 説明（スキル一覧に表示）
allowed-tools: Read, Grep, Glob, Bash    # 使用可能なツール
argument-hint: "[path]"                  # 引数のヒント（任意）
---
```

### 本文

Markdown で手順を記述。以下の要素を含めると効果的：

1. **概要** — 何をするスキルか
2. **実行手順** — Step by Step で記述
3. **コマンド例** — コードブロックで実行コマンド
4. **出力フォーマット** — 結果の報告形式を指定
5. **注意事項** — よくある罠や例外処理

### 引数の参照

```markdown
引数 `$ARGUMENTS` で渡されたパスを対象とする。
```

`/ios-build ~/MyProject` と呼ぶと、`$ARGUMENTS` が `~/MyProject` に展開される。

## 現在のスキル一覧

### iOS 開発

| スキル | 用途 | 使用ツール |
|--------|------|-----------|
| `/ios-build` | XcodeGen → ビルド → テスト | Read, Grep, Glob, Bash |
| `/ios-check` | コードのエラーパターン検出 | Read, Grep, Glob |
| `/ios-reference` | Apple 公式ドキュメント参照 | Read, WebFetch, WebSearch |

### React Native 開発

| スキル | 用途 | 使用ツール |
|--------|------|-----------|
| `/rn-build` | 型チェック → Expo Doctor → テスト | Read, Grep, Glob, Bash |
| `/rn-check` | 認証・ルーティング等の検査 | Read, Grep, Glob |
| `/rn-reference` | RN/Expo ドキュメント参照 | Read, WebFetch, WebSearch |

## 設置場所

### グローバルスキル（全プロジェクト共通）

```
~/.claude/skills/<skill-name>/SKILL.md
```

このリポジトリで管理し、`install.sh` でシンボリックリンクを作成。

### プロジェクトスキル（プロジェクト固有）

```
<project-root>/.claude/skills/<skill-name>/SKILL.md
```

プロジェクトリポジトリ内に直接配置。

## 新しいスキルの作り方

### 1. ディレクトリ作成

```bash
mkdir -p skills/my-new-skill
```

### 2. SKILL.md 作成

```markdown
---
name: my-new-skill
description: 新しいスキルの説明
allowed-tools: Read, Bash
---

# スキルタイトル

## 実行手順

1. ...
2. ...
```

### 3. インストール

```bash
./install.sh  # シンボリックリンクを再作成
```

### 4. 使用

```
/my-new-skill [引数]
```

## スキル設計のベストプラクティス

1. **1スキル1目的** — 複数の目的を混ぜない
2. **出力フォーマットを明示** — 結果の形式を指定すると安定する
3. **エラーケースを記述** — よくある失敗とその対処法
4. **allowed-tools を最小限に** — 不要なツールへのアクセスを制限
5. **コマンドは具体的に** — 曖昧な指示より具体的なシェルコマンド

## 旧形式からの移行

`.claude/commands/*.md` は旧仕様（レガシー）。
`.claude/skills/<name>/SKILL.md` が現在の正式形式。
