#!/bin/bash
# PostToolUse hook: Java 파일 수정 후 컴파일 검증 (mido-client는 단일 모듈)

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# Java 파일이 아니면 스킵
if ! echo "$FILE" | grep -qE '\.java$'; then
    exit 0
fi

# JAVA_HOME 자동 감지
if [ -z "$JAVA_HOME" ]; then
    JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null) || true
fi

# 스크립트 위치 기준으로 프로젝트 루트 결정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# 프로젝트 외부 파일은 스킵 (경로 트래버설 방지)
case "$FILE" in
    "$PROJECT_DIR"/*) ;;
    *)
        echo "[컴파일 스킵] 프로젝트 외부 파일: $FILE"
        exit 0
        ;;
esac

# 컴파일 검증 (단일 모듈: ./gradlew compileJava)
export JAVA_HOME
RESULT=$(cd "$PROJECT_DIR" && ./gradlew compileJava -q 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "컴파일 실패 - 다음 오류를 수정해주세요:"
    echo "$RESULT"
    exit 1
fi

echo "[컴파일 성공] compileJava — $FILE"
exit 0