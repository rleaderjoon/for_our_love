# for_our_love — Windows 설치 스크립트
# 출처: rleaderjoon/for_our_love

Write-Host "`n=== for_our_love 설치 시작 ===" -ForegroundColor Cyan

# ── 1. RTK 설치 ──────────────────────────────────────────
Write-Host "`n[1/3] RTK (Rust Token Killer) 설치 중..." -ForegroundColor Yellow
# TODO: RTK 공식 설치 명령어 확인 후 업데이트 (현재 플레이스홀더)
# 출처: https://github.com/rtk-ai/rtk
if (Get-Command rtk -ErrorAction SilentlyContinue) {
    Write-Host "  RTK 이미 설치됨. 스킵." -ForegroundColor Green
} else {
    Write-Host "  RTK 설치 필요. ATTRIBUTION.md 의 RTK 링크에서 설치 방법 확인." -ForegroundColor Red
    Write-Host "  설치 후 이 스크립트 다시 실행하세요."
}

# ── 2. RTK → CLAUDE.md 주입 ──────────────────────────────
Write-Host "`n[2/3] RTK 글로벌 CLAUDE.md 주입 중..." -ForegroundColor Yellow
if (Get-Command rtk -ErrorAction SilentlyContinue) {
    rtk init --global
    Write-Host "  완료." -ForegroundColor Green
}

# ── 3. context-mode MCP 설치 ─────────────────────────────
Write-Host "`n[3/3] context-mode MCP 설치 중..." -ForegroundColor Yellow
# TODO: context-mode MCP 공식 설치 명령어 확인 후 업데이트
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  context-mode 설치 명령어: docs/how_it_works.md 참조" -ForegroundColor Yellow
} else {
    Write-Host "  Claude Code CLI가 없습니다. https://claude.ai/code 에서 설치 후 재실행." -ForegroundColor Red
}

# ── 완료 안내 ─────────────────────────────────────────────
Write-Host "`n=== 설치 완료 ===" -ForegroundColor Cyan
Write-Host "다음 단계:"
Write-Host "  1. templates/CLAUDE.md 를 프로젝트 루트에 복사"
Write-Host "  2. templates/settings.json 을 프로젝트 .claude/settings.json 에 복사"
Write-Host "  3. 프로젝트 폴더에서 'claude' 실행"
Write-Host ""
