# cli-compact.ps1 — CLI 출력 압축 wrapper 함수
# RTK(Rust Token Killer) 없이 PowerShell native로 동일 효과
# 원리: verbose CLI 출력 → 필터링 → 핵심만 Claude context 진입 (60-80% 절감)
#
# 사용법 (수동): . .\scripts\cli-compact.ps1
# install.ps1이 PowerShell 프로필에 자동 추가
# 출처: rleaderjoon/for_our_love

function git-log  { git log --oneline @args | Select-Object -First 20 }
function git-diff { git diff --stat @args }
function git-st   { git status -s }
function git-br   { git branch @args }
function git-show { git show --stat @args }

function npm-i  { npm install @args 2>&1 | Select-Object -Last 15 }
function pnpm-i { pnpm install @args 2>&1 | Select-Object -Last 15 }

function docker-ps {
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}
function docker-log {
    param([string]$Container, [int]$Lines = 50)
    docker logs $Container --tail $Lines
}

function cargo-b { cargo build @args 2>&1 | Select-Object -Last 20 }
function cargo-t { cargo test @args 2>&1 | Where-Object { $_ -match '(FAILED|ok|error)' } }
