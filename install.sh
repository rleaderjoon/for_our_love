#!/bin/bash
# for_our_love — Mac/Linux 설치 스크립트
# 출처: rleaderjoon/for_our_love

echo "\n=== for_our_love 설치 시작 ==="

# ── 1. RTK 설치 ──────────────────────────────────────────
echo "\n[1/3] RTK (Rust Token Killer) 설치 중..."
# 출처: https://github.com/rtk-ai/rtk
if command -v rtk &> /dev/null; then
    echo "  RTK 이미 설치됨. 스킵."
else
    # TODO: RTK 공식 설치 명령어 확인 후 업데이트
    echo "  RTK 설치 필요. ATTRIBUTION.md 의 RTK 링크에서 설치 방법 확인."
fi

# ── 2. RTK → CLAUDE.md 주입 ──────────────────────────────
echo "\n[2/3] RTK 글로벌 CLAUDE.md 주입 중..."
if command -v rtk &> /dev/null; then
    rtk init --global
    echo "  완료."
fi

# ── 3. context-mode MCP 설치 ─────────────────────────────
echo "\n[3/3] context-mode MCP 설치 중..."
# TODO: context-mode MCP 공식 설치 명령어 확인 후 업데이트
if command -v claude &> /dev/null; then
    echo "  context-mode 설치 명령어: docs/how_it_works.md 참조"
else
    echo "  Claude Code CLI 없음. https://claude.ai/code 설치 후 재실행."
fi

# ── 완료 안내 ─────────────────────────────────────────────
echo "\n=== 설치 완료 ==="
echo "다음 단계:"
echo "  1. templates/CLAUDE.md 를 프로젝트 루트에 복사"
echo "  2. templates/settings.json 을 프로젝트 .claude/settings.json 에 복사"
echo "  3. 프로젝트 폴더에서 'claude' 실행"
