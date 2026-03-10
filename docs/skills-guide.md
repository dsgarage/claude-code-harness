# Skills 作成・管理ガイド

> 出典: [The Complete Guide to Building Skills for Claude](https://docs.anthropic.com/) (Anthropic 公式ガイド)

## Skills とは？

**Skill = フォルダに入った指示書。** Claude に特定のタスクやワークフローの処理方法を教える。

毎回同じ手順を説明し直す代わりに、一度 Skill として定義すれば：
- `/ios-build` で常に同じ品質のビルド手順が実行される
- 手順の漏れがなくなる
- チームや他の開発者と共有できる
- Claude.ai、Claude Code、API の全環境で動作する（**ポータビリティ**）

### MCP との関係: キッチンのたとえ

| MCP（接続性） | Skills（知識） |
|-------------|-------------|
| サービスへの接続を提供 | サービスの使い方を教える |
| リアルタイムデータアクセスとツール呼び出し | ワークフローとベストプラクティスを埋め込む |
| **Claude ができること** | **Claude がどうやるべきか** |

**MCP = プロの厨房**（道具・食材・設備）、**Skills = レシピ**（手順書）。

## 核心原則: Progressive Disclosure（段階的開示）

Skills は **3層構造** でトークン使用量を最小化する：

```
第1層: YAML フロントマター（常にロード）
  → Claude が「このスキルを使うべきか？」を判断する最小情報

第2層: SKILL.md 本文（必要時にロード）
  → スキルが選択されたときの完全な指示

第3層: 追加ファイル（オンデマンド）
  → scripts/, references/, assets/ 内のファイル
  → Claude が必要に応じて参照・実行
```

## ファイル構造

```
your-skill-name/
├── SKILL.md                # 必須 - メイン指示ファイル
├── scripts/                # 任意 - 実行可能コード
│   ├── process_data.py
│   └── validate.sh
├── references/             # 任意 - ドキュメント
│   ├── api-guide.md
│   └── examples/
└── assets/                 # 任意 - テンプレート、フォント等
    └── report-template.md
```

### 命名ルール（厳守）

| ルール | 例 |
|-------|-----|
| ファイル名は `SKILL.md` 完全一致 | `SKILL.MD`, `skill.md` は不可 |
| フォルダ名は kebab-case | `notion-project-setup` |
| スペース不可 | `Notion Project Setup` は不可 |
| アンダースコア不可 | `notion_project_setup` は不可 |
| 大文字不可 | `NotionProjectSetup` は不可 |
| フォルダ内に README.md は置かない | ドキュメントは SKILL.md か references/ に |

## YAML フロントマター: 最重要パート

フロントマターは Claude がスキルをロードするかどうかを決定する。

### 最小形式

```yaml
---
name: your-skill-name
description: What it does. Use when user asks to [specific phrases].
---
```

### 全フィールド

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `name` | 必須 | kebab-case、フォルダ名と一致 |
| `description` | 必須 | 何をするか + いつ使うか。1024文字以内 |
| `allowed-tools` | 任意 | 使用可能なツール制限 |
| `argument-hint` | 任意 | 引数のヒント表示 |
| `license` | 任意 | MIT, Apache-2.0 等 |
| `compatibility` | 任意 | 動作環境要件（500文字以内） |
| `metadata` | 任意 | author, version, mcp-server 等 |

### セキュリティ制限

**フロントマターで禁止されているもの：**
- XML の山括弧（`<` `>`）→ プロンプトインジェクション防止
- name に `"claude"` や `"anthropic"` を含める

### description の書き方（最重要）

**構造:** `[何をするか] + [いつ使うか] + [主な機能]`

**良い例：**
```yaml
# 具体的 + トリガーフレーズあり
description: Figma デザインファイルを解析し、開発者向けハンドオフドキュメントを生成する。
  ユーザーが .fig ファイルをアップロードしたとき、「デザインスペック」「コンポーネントドキュメント」
  「デザインからコードへのハンドオフ」と言ったときに使用。

# スコープ明確化
description: EC サイト向け PayFlow 決済処理。オンライン決済ワークフロー専用。
  一般的な金融クエリには使用しない。
```

**悪い例：**
```yaml
# 曖昧すぎる
description: Helps with projects.

# トリガーフレーズがない
description: Creates sophisticated multi-page documentation systems.

# 技術的すぎてユーザー視点がない
description: Implements the Project entity model with hierarchical relationships.
```

## SKILL.md 本文の書き方

### 推奨テンプレート

```markdown
---
name: your-skill
description: [...]
---

# スキル名

## Instructions

### Step 1: [最初の主要ステップ]
具体的な説明。

```bash
python scripts/fetch_data.py --project-id PROJECT_ID
```
Expected output: [成功時の出力]

### Step 2: [次のステップ]
...

## Examples

### Example 1: [一般的なシナリオ]
User says: "..."
Actions:
1. ...
2. ...
Result: ...

## Common Issues

### Error: [よくあるエラーメッセージ]
Cause: [原因]
Solution: [修正方法]
```

### ベストプラクティス

**具体的・実行可能に書く：**
```markdown
# Good
Run `python scripts/validate.py --input {filename}` to check data format.
If validation fails, common issues include:
- Missing required fields (add them to the CSV)
- Invalid date formats (use YYYY-MM-DD)

# Bad
Validate the data before proceeding.
```

**バンドルリソースを明示参照：**
```markdown
Before writing queries, consult `references/api-patterns.md` for:
- Rate limiting guidance
- Pagination patterns
- Error codes and handling
```

**エラーハンドリングを含める：**
```markdown
## Common Issues

### MCP Connection Failed
If you see "Connection refused":
1. Verify MCP server is running: Check Settings > Extensions
2. Confirm API key is valid
3. Try reconnecting: Settings > Extensions > [Your Service] > Reconnect
```

**重要な指示は目立たせる：**
```markdown
## Important
CRITICAL: Before calling create_project, verify:
- Project name is non-empty
- At least one team member assigned
- Start date is not in the past
```

**SKILL.md は 5,000 語以内に。** 詳細は `references/` に分離してリンク。

## 3つのユースケースカテゴリ

### Category 1: ドキュメント・アセット作成

一貫した高品質な出力物（ドキュメント、プレゼン、アプリ、デザイン、コード）を生成。

**テクニック：**
- スタイルガイド・ブランド基準の埋め込み
- テンプレート構造で出力を統一
- 最終化前の品質チェックリスト
- 外部ツール不要（Claude のビルトイン機能で完結）

### Category 2: ワークフロー自動化

一貫した方法論が求められる複数ステップのプロセス。

**テクニック：**
- バリデーションゲート付きステップバイステップ
- 共通構造のテンプレート
- ビルトインのレビュー・改善提案
- 反復的リファインメントループ

### Category 3: MCP Enhancement

MCP サーバーが提供するツールアクセスを、ワークフロー知識で強化。

**テクニック：**
- 複数の MCP 呼び出しを順序立てて調整
- ドメイン知識の埋め込み
- ユーザーが通常指定するコンテキストの自動提供
- MCP 共通エラーのハンドリング

## 5つの設計パターン

### Pattern 1: Sequential Workflow（順次ワークフロー）

**使い所:** 特定の順序で実行する複数ステップ処理

```
Step 1 → Step 2 → Step 3 → Step 4
```

**テクニック:** 明示的なステップ順序、ステップ間の依存関係、各段階のバリデーション、失敗時のロールバック指示

### Pattern 2: Multi-MCP Coordination（複数 MCP 連携）

**使い所:** 複数サービスにまたがるワークフロー

```
Phase 1: Figma MCP → Phase 2: Drive MCP → Phase 3: Linear MCP → Phase 4: Slack MCP
```

**テクニック:** フェーズ間のデータ受け渡し、次のフェーズ前のバリデーション、集中エラーハンドリング

### Pattern 3: Iterative Refinement（反復改善）

**使い所:** 繰り返しで品質が向上する出力

```
Initial Draft → Quality Check → Refinement Loop → Finalization
                     ↑              │
                     └──────────────┘ (品質閾値を満たすまで繰り返し)
```

**テクニック:** 明示的な品質基準、バリデーションスクリプト、反復停止条件

### Pattern 4: Context-aware Tool Selection（コンテキスト対応ツール選択）

**使い所:** 状況に応じて異なるツールで同じ結果を実現

```
Decision Tree → 条件判定 → 適切な MCP ツール選択 → 実行 → 理由の説明
```

**テクニック:** 明確な判定基準、フォールバック選択肢、選択理由の透明性

### Pattern 5: Domain-specific Intelligence（ドメイン特化知識）

**使い所:** ツールアクセス以上の専門知識が必要

```
Before Processing → コンプライアンスチェック → Processing → Audit Trail
```

**テクニック:** ドメイン知識をロジックに埋め込み、アクション前のコンプライアンス、包括的なドキュメント化

## テスト・イテレーション

### 3つのテストレベル

1. **手動テスト**（Claude.ai で直接実行）— 高速、セットアップ不要
2. **スクリプトテスト**（Claude Code で自動化）— 変更時の繰り返し検証
3. **API テスト**（Skills API で体系的実行）— 定義済みテストセットに対する評価

> **Pro Tip:** まず単一タスクで繰り返し改善してから範囲を広げる

### テストすべき3領域

**1. トリガーテスト** — 正しいタイミングでロードされるか？

```
Should trigger:
- "iOS プロジェクトをビルドして"
- "XcodeGen でビルドしたい"

Should NOT trigger:
- "天気を教えて"
- "Python コードを書いて"
```

**2. 機能テスト** — 正しい出力が生成されるか？

- 有効な出力が生成される
- API 呼び出しが成功する
- エラーハンドリングが機能する
- エッジケースがカバーされている

**3. パフォーマンス比較** — スキルあり vs なしで改善しているか？

```
Without skill:
- ユーザーが毎回手順を説明
- 15 往復のやり取り
- 3 回の API エラーによるリトライ
- 12,000 トークン消費

With skill:
- 自動ワークフロー実行
- 2 回の確認質問のみ
- 0 回の API エラー
- 6,000 トークン消費
```

### イテレーションの指針

**トリガー不足の兆候:**
- スキルがロードされるべき場面でロードされない
- ユーザーが手動で有効化している
→ **対策:** description にキーワードやトリガーフレーズを追加

**トリガー過多の兆候:**
- 無関係なクエリでスキルがロードされる
- ユーザーがスキルを無効化する
→ **対策:** ネガティブトリガー追加、スコープを具体化

**指示が無視される兆候:**
- スキルはロードされるが指示通りに動かない
→ **対策:** 指示を簡潔にする、箇条書き・番号リスト使用、重要指示は先頭に、`## Important` / `## Critical` ヘッダーで目立たせる

### skill-creator ツール

Claude.ai の plugin directory または Claude Code で利用可能：
- 自然言語からスキルを生成
- 適切なフロントマター付き SKILL.md を出力
- トリガーフレーズと構造を提案
- 既存スキルのレビューと改善提案

使い方: `"Use the skill-creator skill to help me build a skill for [your use case]"`

## 配布・共有

### 個人利用

1. スキルフォルダをダウンロード
2. Zip（必要なら）
3. Claude.ai: Settings > Capabilities > Skills でアップロード
4. または Claude Code の skills ディレクトリに配置

### 組織レベル

- 管理者がワークスペース全体にスキルをデプロイ可能
- 自動更新、集中管理

### GitHub で公開

1. パブリックリポジトリでホスト
2. インストール手順付きの README（スキルフォルダ外）
3. 使用例とスクリーンショット
4. MCP ドキュメントからスキルにリンク

### Skills API（プログラマティック利用）

- `/v1/skills` エンドポイントで管理
- Messages API の `container.skills` パラメータでスキル付加
- Claude Agent SDK と連携

## トラブルシューティング

### スキルがアップロードできない

| エラー | 原因 | 対策 |
|-------|------|------|
| "Could not find SKILL.md" | ファイル名の大文字小文字 | `SKILL.md` 完全一致に修正 |
| "Invalid frontmatter" | YAML 書式エラー | `---` 区切り確認、閉じ引用符確認 |
| "Invalid skill name" | 名前にスペースや大文字 | kebab-case に変更 |

### スキルがトリガーされない

- description が曖昧すぎないか？（"Helps with projects" は不可）
- トリガーフレーズが含まれているか？
- ファイルタイプが明記されているか？

**デバッグ:** Claude に `"When would you use the [skill name] skill?"` と聞く。Claude が description を引用するので、不足箇所がわかる。

### スキルがトリガーされすぎる

1. ネガティブトリガーを追加: `"Do NOT use for simple data exploration"`
2. スコープを具体化: `"Processes documents"` → `"Processes PDF legal documents for contract review"`

### 指示が無視される

1. **指示が冗長** → 簡潔に、箇条書き使用、詳細は references/ に分離
2. **重要指示が埋もれている** → 先頭に配置、`## Important` ヘッダー使用
3. **曖昧な表現** → `"Make sure to validate things properly"` → `"CRITICAL: Before calling create_project, verify: ..."`
4. **モデルの怠慢** → Performance Notes セクションで明示的に質を促す

### コンテキストが大きすぎる

1. SKILL.md を 5,000 語以内に → 詳細は references/ に分離
2. 同時有効スキルを 20-50 個以内に評価
3. 関連スキルを「パック」にまとめて選択的有効化を検討

### MCP 接続の問題

1. MCP サーバーが接続済みか確認（Settings > Extensions）
2. API キーの有効期限・権限を確認
3. MCP を単独テスト（スキルなしで直接 MCP 呼び出し）
4. ツール名が大文字小文字含め正確か確認

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

## 参考資料

- [The Complete Guide to Building Skills for Claude](https://docs.anthropic.com/) — Anthropic 公式ガイド
- [anthropics/skills](https://github.com/anthropics/skills) — Anthropic 公式スキルリポジトリ
- [Skills API Quickstart](https://docs.anthropic.com/)
- [skill-creator skill](https://docs.anthropic.com/) — スキル作成支援ツール
- [Claude Developers Discord](https://discord.gg/anthropic) — テクニカルサポート
