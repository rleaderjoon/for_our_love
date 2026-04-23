# 4가지 도구 원리

## 왜 토큰 절감이 중요한가

Claude는 context window에 들어오는 텍스트 양에 따라 응답 품질과 속도가 달라진다.
불필요한 텍스트가 많을수록: 느려지고, 비용이 늘고, 핵심에서 벗어날 확률이 높아진다.

---

## 1. Karpathy 원칙 — 프롬프트 주입

**원리**: `.md` 파일을 context에 로드 → Claude 행동 기준으로 작동

```
CLAUDE.md → 대화 시작 시 자동 로드 → 모든 응답에 영향
```

- 전처리 없음. Python 없음. 텍스트만.
- "단순함 우선" 같은 규칙이 Claude가 코드 생성할 때 기준이 됨.
- **절감 효과**: 잘못된 방향으로 구현 후 되돌리는 비용 방지.

---

## 2. compress_all — 문서 압축

**원리**: `.md` 파일을 텍스트 처리로 압축 → 다음 대화에서 읽을 때 토큰 절감

```
원본 파일 → compress_all.ps1 → 30-60% 압축본 (_AI참고/ 폴더)
                                        ↓
                              CLAUDE.md 지침에서 압축본을 우선 읽도록 설정
```

- 원본은 보존, `_AI참고/` 폴더에 압축본 생성.
- 재실행 시 신규 파일만 처리 (`-Force` 로 전체 재압축).
- 압축 방법: HTML 주석 제거, 연속 빈줄 압축, 트레일링 공백 제거.

### _AI참고/ 폴더 구조 패턴
```
프로젝트/
├── DESIGN_SYSTEM.md        # 원본 (사람이 읽음)
├── docs/API_REFERENCE.md   # 원본
└── _AI참고/
    ├── DESIGN_SYSTEM.md    # 압축본 (Claude가 읽음)
    └── docs/
        └── API_REFERENCE.md
```

---

## 3. CLI compact — 명령어 출력 압축

**원리**: CLI 명령어 출력을 Claude context 진입 전에 필터링

```
RTK(바이너리)의 원리:
  rtk git log → git log 실행 → 전체 출력 가로채기 → 핵심만 추출 → Claude context 진입

for_our_love native 구현 (2레이어):
  레이어 1: CLAUDE.md 지침 → Claude가 처음부터 compact 명령어 선택
  레이어 2: cli-compact.ps1 → PowerShell 함수로 출력 필터링
```

RTK는 모든 명령어에 자동 적용되는 바이너리. Windows에서 존재 미확인이라 제거됨.
native 방식은 지침 기반이므로 Claude가 의식적으로 따라야 효과 있음.

**절감 효과**: git log 50줄 → 20줄 = 60%, npm install 200줄 → 15줄 = 92%

---

## 4. vault-finder — Obsidian 파일 직접 읽기

**원리**: Obsidian vault 위치를 찾아 저장 → Claude가 필요한 노트만 검색해 읽음

```
vault-finder.ps1
  → %APPDATA%\Obsidian\obsidian.json 에서 vault 경로 탐색
  → vault-config.json 저장 (경로 + 파일 수)

Claude 사용 시:
  → vault-config.json 읽어 경로 확인
  → Grep으로 필요한 파일 검색
  → 관련 파일만 Read (전체 vault 로드 안 함)
```

- MCP API 불필요 — 직접 파일시스템 접근, Obsidian 미실행 OK.
- 여러 vault 동시 지원.
- **절감 효과**: vault 전체 로드 수만 토큰 → 필요한 파일만 수백 토큰.

---

## 5. AWS hook — 로컬/AWS 실행 환경 선택

**원리**: Bash 명령어 실행 전 AWS 패턴 감지 → 자격증명 확인 → 선택 유도

```
PreToolUse hook (aws-check.ps1)
  → Claude가 Bash 실행 요청
  → hook이 먼저 실행: 명령어에서 AWS 패턴 감지
  → 자격증명 있음: "로컬/AWS 선택" 메시지 → Claude가 사용자에게 확인
  → 자격증명 없음: "로컬만 가능" 안내
  → exit 2 → Claude Code가 hook 출력 읽고 사용자에게 전달
```

```
프로젝트별 1회 설정 (aws-detect.ps1):
  코드/.env 스캔 → 사용 중인 서비스 감지
  → docker-compose.localstack.yml 자동 생성
  → .env.local.template 복사

실행 환경:
  로컬: docker-compose -f docker-compose.localstack.yml up -d
  AWS:  기존 자격증명으로 실제 AWS 접근
```

- PEM 파일 없는 팀원 → 로컬(Docker) 전용으로 안내.
- 오너(PEM 있음) → 매 실행마다 선택 질문.
- **절감 효과**: 잘못된 환경으로 실행해서 발생하는 에러 디버깅 토큰 방지.

---

## 요약 비교

| 도구 | 원리 | 전처리 | 최적 용도 |
|------|------|--------|---------|
| Karpathy CLAUDE.md | 텍스트 instruction | 없음 | 행동 방향 설정 |
| compress_all | 텍스트 압축 → _AI참고/ | 스크립트 | 자주 읽는 문서 |
| CLI compact | compact 플래그 + PS 함수 | 설정 1회 | git/npm/docker 출력 |
| vault-finder | vault 경로 저장 → 선택적 읽기 | 스크립트 | Obsidian 노트 접근 |
| AWS hook | Bash 실행 전 환경 확인 | hook 설치 | EC2/AWS 프로젝트 |
