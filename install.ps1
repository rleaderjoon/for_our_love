# for_our_love — All-in-One 설치 스크립트
# 사용법: .\install.ps1
# 재실행 안전: 이미 설치된 항목은 스킵
# 출처: rleaderjoon/for_our_love

$ErrorActionPreference = "Stop"
$root  = $PSScriptRoot
$total = 6
$step  = 0

function Step($msg) {
    $script:step++
    $pct = [int](($script:step / $total) * 100)
    Write-Progress -Activity "for_our_love 설치" -Status "[$script:step/$total] $msg" -PercentComplete $pct
}
function OK($msg)   { Write-Host "  OK  $msg" -ForegroundColor Green }
function WARN($msg) { Write-Host "  !!  $msg" -ForegroundColor Yellow }
function FAIL($msg) { Write-Host "  XX  $msg" -ForegroundColor Red }

# ─── 1. Claude Code 확인 ────────────────────────────────────────
Step "Claude Code 확인"
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    FAIL "Claude Code CLI가 없습니다. https://claude.ai/code 설치 후 재실행."
    exit 1
}
OK "Claude Code 발견"

# ─── 2. Obsidian vault 탐색 ──────────────────────────────────────
Step "Obsidian vault 탐색"
& "$root\scripts\vault-finder.ps1" -OutputPath "$root\vault-config.json"

# ─── 3. CLAUDE.md 설정 ────────────────────────────────────────────
Step "CLAUDE.md 설정"

$marker       = "# [for_our_love]"
$globalClaude = "$env:USERPROFILE\.claude\CLAUDE.md"
$template     = "$root\templates\CLAUDE.md"
$appendFile   = "$root\templates\claude-append.md"

if (-not (Test-Path $globalClaude)) {
    $claudeDir = Split-Path $globalClaude
    if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }
    Copy-Item $template $globalClaude
    OK "~\.claude\CLAUDE.md 생성 (for_our_love 기조 전체 포함)"
} else {
    $existing = Get-Content $globalClaude -Raw -Encoding UTF8

    if ($existing.Contains($marker)) {
        OK "~\.claude\CLAUDE.md 이미 설정됨. 스킵."
    } else {
        Write-Progress -Activity "for_our_love 설치" -Status "CLAUDE.md 확인 중..." -PercentComplete 42
        Write-Host ""
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "  기존 CLAUDE.md가 발견됐습니다." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  [y] 덮어쓰기  — for_our_love 기조(Karpathy 원칙 + vault/compress/CLI 지침) 전체 적용"
        Write-Host "       기존 내용은 CLAUDE.md.bak 으로 백업됩니다."
        Write-Host ""
        Write-Host "  [n] 추가만    — 기존 CLAUDE.md 유지, for_our_love 섹션만 끝에 추가 (기본값)"
        Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
        $answer = Read-Host "  선택 [y/N]"

        if ($answer -ieq 'y') {
            Copy-Item $globalClaude "$globalClaude.bak" -Force
            Copy-Item $template $globalClaude -Force
            OK "~\.claude\CLAUDE.md 덮어쓰기 완료 (백업: CLAUDE.md.bak)"
        } else {
            $append = Get-Content $appendFile -Raw -Encoding UTF8
            "`n---`n$append" | Add-Content $globalClaude -Encoding UTF8
            OK "~\.claude\CLAUDE.md 에 for_our_love 섹션 추가 (기존 내용 유지)"
        }
    }
}

# ─── 4. compress_all 실행 ─────────────────────────────────────────
Step "문서 압축 (compress_all)"
& "$root\scripts\compress_all.ps1" -Path $root

# ─── 5. AWS hook 설치 ─────────────────────────────────────────────
Step "AWS 로컬 테스트 hook 설치"

$claudeDir  = "$env:USERPROFILE\.claude"
$hooksDir   = "$claudeDir\hooks"
$hookSrc    = "$root\.claude\hooks\aws-check.ps1"
$hookDst    = "$hooksDir\aws-check.ps1"
$globalSettings = "$claudeDir\settings.json"
$hookCmd    = "powershell -NoProfile -File `"$hookDst`""

# hooks 디렉토리 생성
if (-not (Test-Path $hooksDir)) { New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null }

# aws-check.ps1 복사
Copy-Item $hookSrc $hookDst -Force
OK "aws-check.ps1 → ~\.claude\hooks\"

# ~/.claude/settings.json 에 PreToolUse hook 등록
if (-not (Test-Path $globalSettings)) {
    @"
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "$($hookCmd.Replace('\','\\'))" }]
      }
    ]
  }
}
"@ | Set-Content $globalSettings -Encoding UTF8
    OK "~\.claude\settings.json 생성 + AWS hook 등록"
} else {
    $raw = Get-Content $globalSettings -Raw -Encoding UTF8
    if ($raw -notmatch 'aws-check') {
        $newEntry = '"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"' + $hookCmd.Replace('\','\\').Replace('"','\"') + '"}]}],'
        if ($raw -match '"hooks"\s*:\s*\{') {
            $raw = $raw -replace '("hooks"\s*:\s*\{)', "`$1$newEntry"
        } else {
            $raw = $raw -replace '(\{)', "`$1`"hooks`":{$newEntry},"
        }
        $raw | Set-Content $globalSettings -Encoding UTF8
        OK "~\.claude\settings.json 에 AWS hook 추가"
    } else {
        OK "AWS hook 이미 등록됨. 스킵."
    }
}

# ─── 6. CLI compact 설정 ──────────────────────────────────────────
Step "CLI compact 설정"

$profilePath = $PROFILE.CurrentUserAllHosts
$sourceLine  = ". `"$root\scripts\cli-compact.ps1`""

if (-not (Test-Path $profilePath)) {
    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    $sourceLine | Set-Content $profilePath -Encoding UTF8
    OK "PowerShell 프로필 생성 + cli-compact.ps1 등록"
} else {
    $profileContent = Get-Content $profilePath -Raw -Encoding UTF8
    if (-not $profileContent.Contains("cli-compact")) {
        "`n$sourceLine" | Add-Content $profilePath -Encoding UTF8
        OK "PowerShell 프로필에 cli-compact.ps1 추가"
    } else {
        OK "cli-compact.ps1 이미 프로필에 있음. 스킵."
    }
}

# ─── 완료 ─────────────────────────────────────────────────────────
Write-Progress -Completed -Activity "for_our_love 설치"

Write-Host ""
Write-Host "=== 설치 완료 ===" -ForegroundColor Cyan
Write-Host ""

if (Test-Path "$root\vault-config.json") {
    $vc = Get-Content "$root\vault-config.json" -Raw | ConvertFrom-Json
    Write-Host "  Obsidian vault $($vc.vault_count)개 등록됨 (vault-config.json)"
}
if (Test-Path "$root\_AI참고") {
    Write-Host "  압축 문서 생성됨 (_AI참고/)"
}
Write-Host "  CLAUDE.md 행동 지침 적용됨"
Write-Host "  AWS hook 등록됨 (~\.claude\hooks\aws-check.ps1)"
Write-Host "  CLI compact 함수 등록됨 (git-log, git-st, npm-i 등)"
Write-Host ""
Write-Host "AWS 로컬 테스트 환경 구성 방법 (프로젝트별 1회):" -ForegroundColor DarkGray
Write-Host "  cd C:\내프로젝트" -ForegroundColor DarkGray
Write-Host "  & `"$root\scripts\aws-detect.ps1`" -Path ." -ForegroundColor DarkGray
Write-Host ""
Write-Host "재실행 시 신규 vault 및 문서를 자동으로 처리합니다."
