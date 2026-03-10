#!/bin/bash
# Claude Code Harness インストールスクリプト
# ~/.claude/ 配下にシンボリックリンクを作成する

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Claude Code Harness インストーラー ==="
echo ""
echo "ソース: $SCRIPT_DIR"
echo "ターゲット: $CLAUDE_DIR"
echo ""

# バックアップディレクトリ
BACKUP_DIR="$CLAUDE_DIR/backups/harness-$(date +%Y%m%d-%H%M%S)"

# シンボリックリンクを作成する関数
link_file() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        echo "  既存リンク削除: $dest"
        rm "$dest"
    elif [ -e "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "  バックアップ: $dest → $BACKUP_DIR/"
        cp -r "$dest" "$BACKUP_DIR/"
        rm -rf "$dest"
    fi

    ln -s "$src" "$dest"
    echo "  リンク作成: $dest → $src"
}

# 1. メイン設定ファイル
echo "[1/4] 設定ファイル"
link_file "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
link_file "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
link_file "$SCRIPT_DIR/mcp.json" "$CLAUDE_DIR/mcp.json"

# 2. Hooks
echo ""
echo "[2/4] Hooks"
mkdir -p "$CLAUDE_DIR/hooks"
link_file "$SCRIPT_DIR/hooks/safe_command.py" "$CLAUDE_DIR/hooks/safe_command.py"

# 3. Skills（シンボリックリンクのスキルはスキップ）
echo ""
echo "[3/4] Skills"
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    dest="$CLAUDE_DIR/skills/$skill_name"

    # 既存がシンボリックリンク（XcodeMCP-Skills 等）ならスキップ
    if [ -L "$dest" ] && [[ "$(readlink "$dest")" != "$SCRIPT_DIR"* ]]; then
        echo "  スキップ（外部リンク）: $skill_name → $(readlink "$dest")"
        continue
    fi

    mkdir -p "$CLAUDE_DIR/skills"
    link_file "$skill_dir" "$dest"
done

# 4. 完了
echo ""
echo "[4/4] 検証"
echo ""

errors=0
for f in settings.json CLAUDE.md mcp.json; do
    if [ -L "$CLAUDE_DIR/$f" ]; then
        echo "  OK: $CLAUDE_DIR/$f"
    else
        echo "  NG: $CLAUDE_DIR/$f（リンクなし）"
        errors=$((errors + 1))
    fi
done

if [ -L "$CLAUDE_DIR/hooks/safe_command.py" ]; then
    echo "  OK: $CLAUDE_DIR/hooks/safe_command.py"
else
    echo "  NG: $CLAUDE_DIR/hooks/safe_command.py（リンクなし）"
    errors=$((errors + 1))
fi

echo ""
if [ $errors -eq 0 ]; then
    echo "=== インストール完了 ==="
    if [ -d "$BACKUP_DIR" ]; then
        echo "バックアップ: $BACKUP_DIR"
    fi
else
    echo "=== $errors 件のエラーがあります ==="
    exit 1
fi
