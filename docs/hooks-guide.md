# Hooks システム詳細ガイド

## Hooks とは？

Claude Code の **Hooks** は、エージェントがツールを使う前後に **自動実行されるシェルコマンド**。
人間が毎回チェックしなくても、機械的にルールを強制できる。

## 4 つの Hook ポイント

```
ユーザーの指示
  │
  ▼
┌──────────────────┐
│  エージェント思考  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐     exit 2 でブロック
│  PreToolUse      │───→ エージェントに理由フィードバック
│  (ツール実行前)    │
└──────┬───────────┘
       │ exit 0 で通過
       ▼
┌──────────────────┐
│  ツール実行       │  Bash, Edit, Write など
└──────┬───────────┘
       │
       ▼
┌──────────────────┐     結果を additionalContext で注入
│  PostToolUse     │───→ エージェントが自己修正
│  (ツール実行後)    │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐     テスト不合格なら続行指示
│  Stop            │───→ エージェントは完了を撤回
│  (完了宣言時)      │
└──────┬───────────┘
       │ テスト合格
       ▼
     完了
```

## 設定場所

`~/.claude/settings.json` の `hooks` セクション:

```json
{
  "hooks": {
    "PreToolUse": [ ... ],
    "PostToolUse": [ ... ],
    "Stop": [ ... ],
    "PreCompact": [ ... ]
  }
}
```

## Hook の構造

```json
{
  "matcher": "Bash",           // 対象ツール名（正規表現）
  "hooks": [
    {
      "type": "command",
      "command": "python3 ~/.claude/hooks/safe_command.py"
    }
  ]
}
```

### matcher（対象ツール指定）

| 値 | 意味 |
|----|------|
| `"Bash"` | Bash ツールのみ |
| `"Write\|Edit"` | Write または Edit |
| `""` (空文字) | 全ツール |

### 入力データ

Hook スクリプトは **標準入力（stdin）** から JSON を受け取る：

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /important-dir"
  }
}
```

### 終了コード

| コード | 意味 |
|--------|------|
| `0` | 通過（ツール実行を許可） |
| `2` | **ブロック**（ツール実行を拒否） |
| その他 | 無視（フック自体のエラー） |

### フィードバック

- `exit 2` の場合、**stderr** に出力した内容がエージェントに伝わる
- エージェントはその理由を読んで別のアプローチを試みる

## 現在の設定（このリポジトリ）

### PreToolUse: safe_command.py

**対象:** Bash ツール
**役割:** 危険なコマンドの検出とブロック

| チェック項目 | 例 |
|------------|-----|
| 禁止コマンドパターン | `sudo`, `rm -rf`, `chmod 777`, `curl \| bash` |
| 保護ディレクトリの削除 | `/etc`, `/usr`, `Assets`（Unity） |
| ホーム直下の削除 | `rm ~/important-file` |

## 今後追加予定の Hook

### PostToolUse: 自動リント（Week 1 目標）

ファイル編集後にリンター/フォーマッターを自動実行：

```json
{
  "matcher": "Write|Edit",
  "hooks": [
    {
      "type": "command",
      "command": "bash -c 'FILE=$(jq -r \".tool_input.file_path // .tool_input.path\" <<< \"$(cat)\"); case \"$FILE\" in *.ts|*.tsx|*.js|*.jsx) npx biome format --write \"$FILE\" 2>/dev/null; npx oxlint --fix \"$FILE\" 2>&1 | head -20;; *.py) ruff format \"$FILE\" 2>/dev/null; ruff check --fix \"$FILE\" 2>&1 | head -20;; *.swift) swiftformat \"$FILE\" 2>&1 | head -20;; esac'"
    }
  ]
}
```

### PreToolUse: リンター設定保護（Week 2 目標）

エージェントがリンター設定を変更してエラーを消す行為を防止：

```json
{
  "matcher": "Write|Edit",
  "hooks": [
    {
      "type": "command",
      "command": "bash -c 'FILE=$(jq -r \".tool_input.file_path // .tool_input.path\" <<< \"$(cat)\"); PROTECTED=\".eslintrc eslint.config biome.json pyproject.toml .prettierrc tsconfig.json\"; for p in $PROTECTED; do case \"$FILE\" in *$p*) echo \"BLOCKED: リンター設定ファイル $FILE の変更は禁止されています\" >&2; exit 2;; esac; done'"
    }
  ]
}
```

### Stop: 完了時テスト実行（Week 2 目標）

```json
{
  "matcher": "",
  "hooks": [
    {
      "type": "command",
      "command": "bash -c 'if [ -f package.json ]; then npm test 2>&1 | tail -20; fi'"
    }
  ]
}
```

## デバッグ方法

Hook が期待通り動かない場合：

```bash
# Hook に渡される JSON を確認
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | python3 ~/.claude/hooks/safe_command.py
echo $?  # 2 ならブロック成功
```

## 参考: フィードバック速度の比較

```
PostToolUse Hook   → ミリ秒（ファイル保存のたびに実行）
プリコミットフック   → 秒（git commit 時に実行）
CI/CD             → 分（push 後に実行）
人間レビュー       → 時間（PR 作成後）
```

速いレイヤーで問題を捕まえるほど、修正コストが下がる。
