# vault-finder.ps1 — Obsidian vault 위치 자동 탐색 및 저장
# 출력: 프로젝트 루트의 vault-config.json
# 출처: rleaderjoon/for_our_love

param([string]$OutputPath = "$PSScriptRoot\..\vault-config.json")

$obsidianConfig = "$env:APPDATA\Obsidian\obsidian.json"

if (-not (Test-Path $obsidianConfig)) {
    Write-Host "  Obsidian이 설치되어 있지 않습니다. 스킵." -ForegroundColor Yellow
    exit 0
}

$data = Get-Content $obsidianConfig -Raw -Encoding UTF8 | ConvertFrom-Json
$vaults = @()

foreach ($prop in $data.vaults.PSObject.Properties) {
    $vault = $prop.Value
    if ($vault.path -and (Test-Path $vault.path)) {
        $mdCount = (Get-ChildItem -Path $vault.path -Filter "*.md" -Recurse -ErrorAction SilentlyContinue).Count
        $vaults += [ordered]@{
            name  = Split-Path $vault.path -Leaf
            path  = $vault.path
            md_files = $mdCount
        }
    }
}

$output = [ordered]@{
    generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    vault_count = $vaults.Count
    vaults = $vaults
}

$output | ConvertTo-Json -Depth 5 | Set-Content $OutputPath -Encoding UTF8

Write-Host "  발견된 vault: $($vaults.Count)개" -ForegroundColor Green
foreach ($v in $vaults) {
    Write-Host "    - $($v.name) ($($v.md_files)개 .md 파일): $($v.path)"
}
