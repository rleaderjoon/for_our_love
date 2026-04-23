# for_our_love

> Claude Code를 팀 전체가 더 잘 쓰기 위한 올인원 설치 도구.
> `.\install.ps1` 한 번으로 토큰 절감 + 코드 품질 + 로컬 테스트 환경까지 셋업.

---

## 빠른 시작

```powershell
# 1. 클론
git clone https://github.com/janghyojoon/for_our_love.git
cd for_our_love

# 2. 설치 (한 번만)
.\install.ps1
```

Mac/Linux:
```bash
git clone https://github.com/janghyojoon/for_our_love.git
cd for_our_love
chmod +x install.sh && ./install.sh
```

**설치 시간: 약 1분. 이후 Claude Code를 열면 모든 설정이 자동 적용됩니다.**

---

## 설치하면 어떤 일이 일어나는가

```
[1/6] Claude Code 설치 여부 확인
[2/6] Obsidian vault 위치 자동 탐색 → vault-config.json 저장
[3/6] CLAUDE.md 행동 지침 설정 (기존 파일 있으면 유지 or 교체 선택)
[4/6] 프로젝트 문서 압축 → _AI참고/ 폴더 생성
[5/6] AWS 실행 환경 확인 hook 설치 → ~/.claude/hooks/
[6/6] CLI 출력 압축 함수 등록 → PowerShell 프로필
```

---

## 설치 후 해야 할 것

### 1. AWS 프로젝트를 팀과 공유하는 경우 (선택)

팀원들이 PEM / AWS 자격증명 없이 로컬에서 테스트하려면 **프로젝트 폴더에서 1회 실행**:

```powershell
cd C:\내프로젝트
& "C:\for_our_love\scripts\aws-detect.ps1" -Path .
```

자동으로:
- 사용 중인 AWS 서비스 감지 (RDS, Redis, S3, Lambda 등)
- `docker-compose.localstack.yml` 생성
- `.env.local.template` 복사

이후 팀원들은:
```powershell
docker-compose -f docker-compose.localstack.yml up -d   # 로컬 서비스 시작
copy .env.local.template .env.local                     # 환경변수 설정
```

### 2. Obsidian을 Claude와 함께 쓰는 경우 (자동 완료)

설치 시 vault 위치가 자동으로 `vault-config.json`에 저장됩니다.
기존에 Obsidian MCP 플러그인을 사용했다면 **제거해도 됩니다.**
Claude가 직접 파일시스템에서 읽으므로 Obsidian이 꺼져 있어도 작동합니다.

### 3. 새 프로젝트에서 Claude Code 시작 시 (권장)

```powershell
# 프로젝트의 .claude/ 폴더에 설정 복사
copy C:\for_our_love\templates\settings.json .claude\settings.json
```

---

## 무엇이 달라지는가

### Claude Code 사용 중 토큰 절감

| 상황 | 기존 | 설치 후 |
|------|------|---------|
| `git log` 실행 | 수백 줄 전체 context 진입 | `--oneline -20` 20줄만 (95% 절감) |
| 프로젝트 문서 읽기 | 원본 파일 전체 로드 | `_AI참고/` 압축본 우선 (30-60% 절감) |
| Obsidian 노트 접근 | 전체 vault 로드 또는 API 호출 | 인덱스 → 검색 → 필요한 파일만 (90%+ 절감) |
| AWS 명령 실행 | 잘못된 환경에서 실행 후 에러 디버깅 | 실행 전 "로컬/AWS?" 질문으로 방지 |

### Claude의 코드 작성 품질

CLAUDE.md에 Karpathy 원칙이 주입되어 Claude가 처음부터:
- 요청하지 않은 기능을 추가하지 않음
- 발생할 수 없는 에러 핸들링을 쓰지 않음
- 불확실하면 가정하지 않고 먼저 물어봄
- 미래를 위한 추상화를 만들지 않음

**효과: 잘못된 방향으로 구현 후 되돌리는 "수정 왕복 비용" 방지.**

---

## 포함된 도구 (5가지)

| 도구 | 파일 | 작동 시점 | 절감 효과 |
|------|------|----------|----------|
| **Karpathy CLAUDE.md** | `templates/CLAUDE.md` | 매 대화 시작 | 잘못된 구현 왕복 비용 |
| **compress_all** | `scripts/compress_all.ps1` | 설치 + 재실행 시 | 문서 읽기 30-60% |
| **vault-finder** | `scripts/vault-finder.ps1` | 설치 시 1회 | Obsidian 접근 90%+ |
| **CLI compact** | `scripts/cli-compact.ps1` | 터미널 세션마다 | git/npm 출력 60-95% |
| **AWS hook** | `.claude/hooks/aws-check.ps1` | Bash 실행 직전 | 잘못된 환경 실행 방지 |

### CLI compact 사용 가능한 함수

설치 후 터미널 새로 열면 바로 사용:

```powershell
git-log       # git log --oneline (최근 20개)
git-st        # git status -s
git-diff      # git diff --stat
git-br        # git branch
npm-i         # npm install (마지막 15줄만)
pnpm-i        # pnpm install (마지막 15줄만)
docker-ps     # docker ps (핵심 컬럼만)
docker-log    # docker logs (마지막 50줄)
```

### AWS hook 작동 방식

Claude Code에서 앱 실행/배포 명령을 쓰려 할 때 자동으로 개입:

```
python app.py 실행 시도
  → AWS 자격증명 있음: "로컬(Docker)에서 실행할까요, AWS에서 실행할까요?"
  → AWS 자격증명 없음: "자격증명 없음. 로컬(Docker)에서만 실행 가능합니다."
```

감지하는 명령: `python *.py`, `npm start`, `node *.js`, `ssh -i *.pem`, `docker-compose up`, `sam deploy` 등

---

## 파일 구조

```
for_our_love/
├── install.ps1                    ← Windows 설치 진입점
├── install.sh                     ← Mac/Linux 설치 진입점
│
├── scripts/
│   ├── vault-finder.ps1           ← Obsidian vault 위치 탐색
│   ├── compress_all.ps1           ← .md 문서 압축 → _AI참고/
│   ├── cli-compact.ps1            ← CLI 출력 압축 wrapper 함수
│   └── aws-detect.ps1             ← AWS 서비스 감지 + 로컬 환경 구성
│
├── .claude/
│   ├── settings.json              ← 이 프로젝트용 Claude Code 설정
│   └── hooks/
│       └── aws-check.ps1          ← PreToolUse hook (설치 시 ~/.claude/hooks/ 에 복사됨)
│
├── templates/
│   ├── CLAUDE.md                  ← 팀 공유 행동 지침 (Karpathy 원칙)
│   ├── claude-append.md           ← 기존 CLAUDE.md에 추가되는 섹션
│   ├── settings.json              ← 프로젝트 Claude Code 설정 템플릿
│   └── aws-local/
│       ├── docker-compose.template.yml  ← 로컬 AWS 서비스 템플릿
│       └── .env.local.template    ← 로컬 환경변수 템플릿
│
├── docs/
│   └── how_it_works.md            ← 각 도구 원리 상세 설명
├── suggest.md                     ← LLM 토큰 구조 이해 가이드
└── ATTRIBUTION.md                 ← 출처 명시
```

---

## 자주 묻는 것

**Q. 기존에 Obsidian MCP 플러그인을 쓰고 있었는데?**
대부분의 경우 제거해도 됩니다. vault-finder는 Obsidian 앱 없이 파일을 직접 읽습니다.
단, 의미 기반(벡터) 검색을 사용했다면 키워드 검색으로 대체됩니다.

**Q. 팀원은 AWS 자격증명이 없는데?**
`aws-detect.ps1`을 실행하면 `docker-compose.localstack.yml`이 생성됩니다.
Docker를 설치하고 `docker-compose up`으로 로컬 환경을 시작하면 됩니다.

**Q. CLAUDE.md가 이미 있는데 덮어써지나?**
설치 시 선택합니다. `y` = 기존 파일 백업(`CLAUDE.md.bak`) 후 교체, `n` = 기존 내용 유지 + for_our_love 섹션만 추가.

**Q. 재설치(재실행)해도 안전한가?**
안전합니다. 이미 설치된 항목은 모두 스킵합니다. 신규 .md 파일만 압축됩니다.

---

## 출처

각 도구의 원본 출처 → `ATTRIBUTION.md`
