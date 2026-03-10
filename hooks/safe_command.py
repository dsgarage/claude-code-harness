#!/usr/bin/env python3
import json
import re
import sys
import os

# 削除を禁止するディレクトリ（配下も含む）
PROTECTED_DIRS = [
    "/etc",
    "/usr",
    "/var",
    "/opt",
    "/home",
    "Assets",           # Unityプロジェクトのアセット
    "ProjectSettings",  # Unity設定
    "Library",          # Unityキャッシュ
]

# 禁止するコマンドパターン（正規表現）
FORBIDDEN_COMMANDS = [
    r"\bsudo\b",
    r"\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\b",
    r"\brm\s+.*\*",
    r"\bchmod\s+777\b",
    r"curl.*\|\s*(bash|sh)",
    r"wget.*\|\s*(bash|sh)",
    r":\(\)",
    r"\bdd\s+.*of=/dev/",
    r"\bmkfs\b",
    r">\s*/dev/(sd|hd|nvme)",
]

# 削除系コマンドのパターン
DELETE_COMMANDS = [
    r"\brm\b",
    r"\brmdir\b",
    r"\bunlink\b",
    r"\bfind\b.*-delete",
    r"\bfind\b.*-exec\s+rm",
    r"\bxargs\s+rm",
]


def _check_protected_directory_deletion(command: str) -> bool:
    """保護されたディレクトリへの削除操作をチェック"""
    has_delete = any(re.search(pattern, command, re.IGNORECASE)
                     for pattern in DELETE_COMMANDS)
    if not has_delete:
        return False

    for protected_dir in PROTECTED_DIRS:
        if re.search(re.escape(protected_dir), command):
            return True

    return False


def _check_home_directory_deletion(command: str) -> bool:
    """ホームディレクトリ直下の削除操作をチェック"""
    home = os.path.expanduser("~")

    has_delete = any(re.search(pattern, command, re.IGNORECASE)
                     for pattern in DELETE_COMMANDS)
    if not has_delete:
        return False

    home_patterns = [
        rf"{re.escape(home)}/[^/\s]+(?:\s|$)",
        r"~/[^/\s]+(?:\s|$)",
        r"\$HOME/[^/\s]+(?:\s|$)",
    ]

    return any(re.search(pattern, command) for pattern in home_patterns)


def _validate_command(command: str) -> list[str]:
    issues = []

    if _check_protected_directory_deletion(command):
        issues.append("保護されたディレクトリの削除は禁止されています")

    if _check_home_directory_deletion(command):
        issues.append("ホームディレクトリ直下の削除は禁止されています")

    for pattern in FORBIDDEN_COMMANDS:
        if re.search(pattern, command, re.IGNORECASE):
            issues.append(f"禁止されたコマンドパターンが検出されました: {pattern}")
            break

    return issues


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if input_data.get("tool_name") != "Bash":
        sys.exit(0)

    command = input_data.get("tool_input", {}).get("command", "")
    if not command:
        sys.exit(0)

    issues = _validate_command(command)
    if issues:
        print("⚠️ 危険なコマンドが検出されました:", file=sys.stderr)
        for issue in issues:
            print(f"• {issue}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
