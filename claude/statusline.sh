#!/bin/bash
# 標準入力からJSON形式のデータを読み込む
input=$(cat)

# 色定義
C_BLUE=$'\033[38;5;69m'
C_DARK_BLUE=$'\033[34m'
C_ORANGE=$'\033[38;5;208m'
C_GREEN=$'\033[32m'
C_YELLOW=$'\033[33m'
C_RESET=$'\033[0m'

# 各種情報を取得
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "."')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
used=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# ディレクトリ名（basename）
dir_name=$(basename "$current_dir")

# ブランチ名（Gitリポジトリ外では空）
branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)

# コストを小数点2桁でフォーマット
cost_formatted=$(printf '$%.2f' "$cost")

# ブランチ部分（Gitリポジトリ外では省略）
if [ -n "$branch" ]; then
  branch_part=" | ${C_ORANGE}(${branch})${C_RESET}"
else
  branch_part=""
fi

# ステータスライン表示
echo "${model} | ${C_BLUE}${dir_name}${C_RESET}${branch_part} | ${C_DARK_BLUE}↑${input_tokens} ↓${output_tokens}${C_RESET} | ${C_GREEN}${used}%${C_RESET} | ${C_YELLOW}${cost_formatted}${C_RESET}"
