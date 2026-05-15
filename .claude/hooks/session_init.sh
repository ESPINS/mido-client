#!/bin/bash
# SessionStart hook: 세션 시작 시 pipeline + skill 설정 자동 주입
# stdout이 Claude 컨텍스트에 주입되어 claude_init.skill.yaml 역할을 자동 수행

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
CLAUDE_DIR="$PROJECT_DIR/.claude"

echo "=== [CLAUDE INIT] 세션 설정 자동 로드 ==="
echo ""

for FILE in pipeline.yaml skills/dev-agent/SKILL.md skills/test-agent/SKILL.md skills/quality-agent/SKILL.md skills/security-agent/SKILL.md; do
    FULL_PATH="$CLAUDE_DIR/$FILE"
    if [ -f "$FULL_PATH" ]; then
        echo "--- $FILE ---"
        cat "$FULL_PATH"
        echo ""
    fi
done

echo "=== Claude 설정이 로드되었습니다. 대기 상태로 전환합니다. ==="
