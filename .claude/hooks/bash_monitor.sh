#!/bin/bash
# PostToolUse hook: Bash 명령 모니터링 — 테스트/커밋 감지

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

if echo "$CMD" | grep -qE 'gradlew.*(test|Test)'; then
    echo "[testing] 테스트 실행 감지"
elif echo "$CMD" | grep -qE 'git.*(push|commit)'; then
    echo "[quality] 커밋/푸시 감지 → quality_agent 점검 권장"
fi
