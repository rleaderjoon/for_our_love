# compress_all.ps1 — .md 파일을 _AI참고/ 폴더에 압축 저장
# 압축 방법: HTML 주석 제거, 연속 빈줄 압축, 트레일링 공백 제거
# 재실행 시 신규/변경 파일만 처리 (--Force 로 전체 재압축)
# 출처: rleaderjoon/for_our_love

param(
    [string]$Path = ".",
    [switch]$Force
)

$resolvedPath = (Resolve-Path $Path).Path
$aiFolder = Join-Path $resolvedPath "_AI참고"

$mdFiles = Get-ChildItem -Path $resolvedPath -Filter "*.md" -Recurse |
    Where-Object { $_.FullName -notmatch [regex]::Escape("_AI참고") }

$total = $mdFiles.Count
if ($total -eq 0) {
    Write-Host "  압축할 .md 파일이 없습니다." -ForegroundColor Yellow
    exit 0
}

$beforeTotal = 0
$afterTotal  = 0
$processed   = 0
$skipped     = 0
$i = 0

foreach ($file in $mdFiles) {
    $i++
    $pct = [int](($i / $total) * 100)
    Write-Progress -Activity "compress_all" -Status $file.Name -PercentComplete $pct

    $relative = $file.FullName.Substring($resolvedPath.Length).TrimStart('\', '/')
    $outPath  = Join-Path $aiFolder $relative

    # 이미 압축본이 있고 Force 없으면 스킵
    if ((Test-Path $outPath) -and -not $Force) {
        $skipped++
        continue
    }

    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    if (-not $content) { $skipped++; continue }

    $beforeTotal += $content.Length

    $compressed = $content
    # HTML 주석 제거
    $compressed = [regex]::Replace($compressed, '<!--[\s\S]*?-->', '')
    # CRLF → LF
    $compressed = $compressed -replace '\r\n', "`n"
    # 3줄 이상 빈줄 → 2줄
    $compressed = [regex]::Replace($compressed, '\n{3,}', "`n`n")
    # 트레일링 공백
    $compressed = [regex]::Replace($compressed, '[ \t]+\n', "`n")
    $compressed = $compressed.Trim()

    $afterTotal += $compressed.Length

    $outDir = Split-Path $outPath
    if (-not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($outPath, $compressed, [System.Text.Encoding]::UTF8)
    $processed++
}

Write-Progress -Completed -Activity "compress_all"

$saved = $beforeTotal - $afterTotal
$pct   = if ($beforeTotal -gt 0) { [int](($saved / $beforeTotal) * 100) } else { 0 }

Write-Host ""
Write-Host "  처리: $processed 파일 | 스킵(기존): $skipped 파일" -ForegroundColor Cyan
if ($processed -gt 0) {
    Write-Host "  $beforeTotal 문자 → $afterTotal 문자 ($pct% 절감)" -ForegroundColor Green
    Write-Host "  저장 위치: _AI참고/"
}
