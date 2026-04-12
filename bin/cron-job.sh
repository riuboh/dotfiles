#!/bin/bash
export PATH="/home/user/.bun/bin:$PATH"
export HOME=/home/user

/home/user/.local/bin/claude -p "PRTIMESのRSS(https://prtimes.jp/index.rdf)を見て「農業」「人材」「スポットワーク」「スキマバイト」「AI」関連の話題を抽出し関連度が高そうなものから最大10個抽出し,discordのチャンネル:1492397421274337320に内容と記事URLを送信して"
