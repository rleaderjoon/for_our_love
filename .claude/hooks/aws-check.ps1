# aws-check.ps1 — Claude Code PreToolUse hook
# 실행/배포 명령 감지 → "로컬 또는 AWS?" 선택 유도
# exit 2 = Claude Code가 hook 출력을 읽고 사용자에게 전달
# 출처: rleaderjoon/for_our_love

# stdin에서 tool input JSON 읽기
$toolInput = $null
try {
    if ([Console]::IsInputRedirected) {
        $raw = [Console]::In.ReadToEnd()
        if ($raw) { $toolInput = $raw | ConvertFrom-Json -ErrorAction Stop }
    }
} catch { }

if (-not $toolInput) { exit 0 }
$cmd = $toolInput.command
if (-not $cmd) { exit 0 }

# 실행/배포 패턴만 감지 (읽기 전용 조회는 제외)
$runPatterns = @(
    'ssh\s+.*-i\s+\S+\.pem',              # EC2 SSH 접속
    'scp\s+.*-i\s+\S+\.pem',              # EC2 파일 전송/배포
    '\baws\s+(deploy|eb\s+deploy)\b',      # AWS 배포
    '\bsam\s+deploy\b',                    # SAM 배포
    '\bserverless\s+deploy\b',             # Serverless 배포
    '\bdocker-compose\s+up\b',             # 서비스 시작
    '\bdocker\s+run\b',                    # 컨테이너 실행
    '\b(gunicorn|uvicorn|hypercorn)\b',    # Python 앱 서버
    '\bnpm\s+(start|run\s+start)\b',       # Node 앱 시작
    '\bnode\s+\S+\.(js|ts)\b',            # Node 직접 실행
    '\bpython\s+\S+\.py\b'                # Python 직접 실행
)

$isExecution = $false
foreach ($p in $runPatterns) {
    if ($cmd -match $p) { $isExecution = $true; break }
}

if (-not $isExecution) { exit 0 }

# 자격증명 확인
$hasCredentials = (Test-Path "$env:USERPROFILE\.aws\credentials") -or
                  ($env:AWS_ACCESS_KEY_ID -and $env:AWS_ACCESS_KEY_ID -notin @('', 'test')) -or
                  (Get-ChildItem -Path . -Filter "*.pem" -ErrorAction SilentlyContinue |
                   Measure-Object).Count -gt 0

$hasLocal = Test-Path "docker-compose.localstack.yml"

if ($hasCredentials) {
    $localStatus = if ($hasLocal) { "준비됨 (docker-compose.localstack.yml)" } else { "미설정 (aws-detect.ps1 필요)" }
    Write-Host "[실행/배포 확인]
로컬에서 실행할까요, AWS에 올려서 실행할까요?

  로컬 (Docker): $localStatus
  AWS  (실제):   자격증명 확인됨

사용자에게 어디서 실행할지 선택해 달라고 물어보세요."
} else {
    Write-Host "[실행/배포 확인 — AWS 자격증명 없음]
AWS 자격증명(PEM 또는 ~/.aws/credentials)이 없습니다.
로컬(Docker Compose)에서만 실행 가능합니다.

로컬 환경 준비:
  1. aws-detect.ps1 -Path . 실행
  2. docker-compose -f docker-compose.localstack.yml up -d
  3. .env.local 파일 설정 후 재시도"
}

exit 2
