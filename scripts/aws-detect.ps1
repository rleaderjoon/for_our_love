# aws-detect.ps1 — AWS 서비스 감지 + 로컬 환경 자동 구성
# 사용법: .\scripts\aws-detect.ps1 -Path C:\myproject
# 출력: aws-services.json, docker-compose.localstack.yml, .env.local.template
# 출처: rleaderjoon/for_our_love

param([string]$Path = ".")

$resolvedPath = (Resolve-Path $Path).Path
$scriptRoot   = $PSScriptRoot
$detected     = [System.Collections.Generic.List[string]]::new()
$hasPem       = $false

Write-Progress -Activity "AWS 서비스 감지" -Status ".env 파일 스캔..." -PercentComplete 10

# ─── .env* 파일 스캔 ────────────────────────────────────────────
$envFiles = Get-ChildItem -Path $resolvedPath -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\.(env)(\b|$)' -or $_.Name -match '^\.(env)\.' }

foreach ($f in $envFiles) {
    $c = Get-Content $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $c) { continue }
    if ($c -match 'DB_HOST\s*=.*\.amazonaws\.com')           { $detected.Add('rds')          }
    if ($c -match 'REDIS_(URL|HOST)\s*=.*\.amazonaws\.com')  { $detected.Add('elasticache')   }
    if ($c -match 'AWS_ACCESS_KEY_ID\s*=\S')                 { $detected.Add('aws-sdk')       }
    if ($c -match 'S3_BUCKET\s*=')                           { $detected.Add('s3')            }
}

Write-Progress -Activity "AWS 서비스 감지" -Status "Python 의존성 확인..." -PercentComplete 25

# ─── requirements.txt ───────────────────────────────────────────
$reqFile = Join-Path $resolvedPath "requirements.txt"
if (Test-Path $reqFile) {
    $req = Get-Content $reqFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($req -match '\bboto3\b') { $detected.Add('boto3') }
}

Write-Progress -Activity "AWS 서비스 감지" -Status "Node.js 의존성 확인..." -PercentComplete 35

# ─── package.json ───────────────────────────────────────────────
$pkgFile = Join-Path $resolvedPath "package.json"
if (Test-Path $pkgFile) {
    $pkg = Get-Content $pkgFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($pkg -match '@aws-sdk/')   { $detected.Add('aws-sdk-js') }
    if ($pkg -match '"aws-sdk"')   { $detected.Add('aws-sdk-js') }
}

Write-Progress -Activity "AWS 서비스 감지" -Status "Python 코드 패턴 검색..." -PercentComplete 50

# ─── Python 코드 스캔 ───────────────────────────────────────────
$pyFiles = Get-ChildItem -Path $resolvedPath -Filter "*.py" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '(venv|__pycache__|\.git|node_modules)' } |
    Select-Object -First 50

foreach ($f in $pyFiles) {
    $c = Get-Content $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $c) { continue }
    if ($c -match "boto3\.client\(['""]s3['""]")       { $detected.Add('s3')        }
    if ($c -match "boto3\.client\(['""]dynamodb['""]") { $detected.Add('dynamodb')  }
    if ($c -match "boto3\.client\(['""]sqs['""]")      { $detected.Add('sqs')       }
    if ($c -match "boto3\.client\(['""]lambda['""]")   { $detected.Add('lambda')    }
    if ($c -match "boto3\.client\(['""]rds['""]")      { $detected.Add('rds')       }
}

Write-Progress -Activity "AWS 서비스 감지" -Status "PEM 파일 확인..." -PercentComplete 75

# ─── PEM 파일 ───────────────────────────────────────────────────
$pem = Get-ChildItem -Path $resolvedPath -Filter "*.pem" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\.git' }
if ($pem.Count -gt 0) { $hasPem = $true; $detected.Add('ec2-ssh') }

$detected = ($detected | Select-Object -Unique)

# ─── aws-services.json 저장 ─────────────────────────────────────
Write-Progress -Activity "AWS 서비스 감지" -Status "결과 저장..." -PercentComplete 85

$outJson = Join-Path $resolvedPath "aws-services.json"
[ordered]@{
    detected   = @($detected)
    has_pem    = $hasPem
    scanned_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    path       = $resolvedPath
} | ConvertTo-Json -Depth 3 | Set-Content $outJson -Encoding UTF8

# ─── docker-compose.localstack.yml 생성 ─────────────────────────
$services  = [System.Collections.Generic.List[string]]::new()
$volumes   = [System.Collections.Generic.List[string]]::new()
$lsServices = [System.Collections.Generic.List[string]]::new()

if (($detected -contains 'rds') -or ($detected -contains 'boto3' -and $detected -notcontains 's3')) {
    $services.Add(@"
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: `${DB_NAME:-app}
      POSTGRES_USER: `${DB_USER:-postgres}
      POSTGRES_PASSWORD: `${DB_PASSWORD:-postgres}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
"@)
    $volumes.Add("  postgres_data:")
}

if ($detected -contains 'elasticache') {
    $services.Add(@"
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
"@)
}

if ($detected -contains 's3')       { $lsServices.Add('s3') }
if ($detected -contains 'dynamodb') { $lsServices.Add('dynamodb') }
if ($detected -contains 'sqs')      { $lsServices.Add('sqs') }
if ($detected -contains 'lambda')   { $lsServices.Add('lambda') }

if ($lsServices.Count -gt 0) {
    $services.Add(@"
  localstack:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"
    environment:
      SERVICES: $($lsServices -join ',')
      DEBUG: 0
    volumes:
      - localstack_data:/var/lib/localstack
"@)
    $volumes.Add("  localstack_data:")
}

$volumeSection = if ($volumes.Count -gt 0) { "`nvolumes:`n$($volumes -join "`n")" } else { "" }

if ($services.Count -gt 0) {
    $composeOut = Join-Path $resolvedPath "docker-compose.localstack.yml"
    @"
# docker-compose.localstack.yml — AWS 서비스 로컬 에뮬레이션
# 자동 생성됨 by for_our_love aws-detect.ps1 ($(Get-Date -Format 'yyyy-MM-dd'))
# 사용법: docker-compose -f docker-compose.localstack.yml up -d

version: '3.8'
services:
$($services -join "`n")
$volumeSection
"@ | Set-Content $composeOut -Encoding UTF8
}

# ─── .env.local.template 복사 ───────────────────────────────────
$envTemplateSrc = Join-Path $scriptRoot "..\templates\aws-local\.env.local.template"
$envTemplateDst = Join-Path $resolvedPath ".env.local.template"
if ((Test-Path $envTemplateSrc) -and -not (Test-Path $envTemplateDst)) {
    Copy-Item $envTemplateSrc $envTemplateDst
}

Write-Progress -Completed -Activity "AWS 서비스 감지"

Write-Host ""
if ($detected.Count -gt 0) {
    Write-Host "  감지된 서비스: $($detected -join ', ')" -ForegroundColor Green
} else {
    Write-Host "  AWS 서비스가 감지되지 않았습니다." -ForegroundColor Yellow
}
Write-Host "  aws-services.json 저장됨"
if ($services.Count -gt 0) {
    Write-Host "  docker-compose.localstack.yml 생성됨"
    Write-Host "    시작: docker-compose -f docker-compose.localstack.yml up -d"
}
if (-not (Test-Path $envTemplateDst) -eq $false) {
    Write-Host "  .env.local.template 복사됨 → .env.local 로 이름 변경 후 값 수정"
}
