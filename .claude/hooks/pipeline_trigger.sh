#!/bin/bash
# UserPromptSubmit hook: 개발 트리거 감지 → pipeline.yaml 파이프라인 지시문 주입
# triggers.yaml develop 섹션에서 패턴을 동적으로 로드 (수동 동기화 불필요)

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TRIGGERS_FILE="$PROJECT_DIR/.claude/triggers.yaml"

# triggers.yaml develop 섹션만 정확히 추출 (다음 섹션 헤더에서 중단)
TRIGGERS=""
if [ -f "$TRIGGERS_FILE" ]; then
    TRIGGERS=$(awk '/^develop:/{f=1;next} f && /^[^ \t]/{exit} f && /^  - /{print}' "$TRIGGERS_FILE" \
        | sed 's/^  - "//; s/"$//' \
        | tr '\n' '|' \
        | sed 's/|$//')
fi

# 단일 단어 exact 패턴 (포함 검색하면 오탐 가능성이 높은 짧은 단어)
EXACT_PATTERN="^(dev|개발|구현|작업|implement|refactor)$"

TRIGGERED=false
if [ -n "$TRIGGERS" ] && echo "$PROMPT" | grep -qE "($TRIGGERS)"; then
    TRIGGERED=true
elif echo "$PROMPT" | grep -qE "$EXACT_PATTERN"; then
    TRIGGERED=true
fi

if [ "$TRIGGERED" = true ]; then
    cat << 'EOF'
[PIPELINE ACTIVATED] pipeline.yaml의 4단계 파이프라인을 순서대로 실행하세요.
단계별 규칙:
  1. [development] dev_agent.skill.yaml 규칙 적용 → 코드 작성/수정
     - PostToolUse 훅(compile_check.sh)이 Java 파일 수정 시 컴파일 자동 검증
     - 컴파일 실패 시 즉시 수정 후 재검증
  2. [testing]     test_agent.skill.yaml 규칙 적용 → JUnit 테스트 작성 및 실행
  3. [quality]     quality_agent.skill.yaml 규칙 적용 → SonarLint/IntelliJ 기준 품질 검증
  4. [security]    security_agent.skill.yaml 규칙 적용 → OWASP 기준 보안 점검

실행 규칙:
  - 각 단계 완료 후 사용자에게 결과를 보고하고 다음 단계 진행 승인을 받을 것 (require_approval_before_next_stage: true)
  - 단계 실패 시 해당 단계에서 중단하고 원인을 보고할 것 (stop_on_failure: true)
EOF
fi

exit 0
