# suggest.md — LLM·에이전트 토큰 구조 이해

> 이 파일은 for_our_love 최적화를 더 잘 설계하기 위한 배경 지식입니다.
> 이 구조를 이해하면 "어디서 토큰이 새는지"를 정확히 짚을 수 있습니다.

---

## 1. 토큰의 종류 (비용 발생 위치)

| 종류 | 설명 | 비용 |
|------|------|------|
| **입력 토큰** | Claude가 읽는 모든 것 (system prompt + 대화 기록 + tool 결과) | 과금 |
| **출력 토큰** | Claude가 쓰는 텍스트 + tool 호출 | 과금 (입력보다 비쌈) |
| **캐시 히트** | 이전에 캐싱된 입력 prefix 재사용 | 90% 할인 |
| **Thinking 토큰** | Extended Thinking 모드의 내부 추론 | 과금 (숨겨져 있어도) |

### 핵심: Thinking 토큰은 숨겨도 과금된다
Claude의 `<thinking>` 블록은 사용자에게 보이지 않게 설정해도 내부적으로 생성되어 과금됩니다.
스크립트로 출력을 필터링해도 모델이 이미 생성한 토큰은 과금 후입니다.
→ Thinking을 줄이려면 API 레벨에서 `budget_tokens`를 낮춰야 함 (Claude Code 자체는 설정 불가).

---

## 2. Claude Code 에이전트의 토큰 흐름

```
대화 시작
  └─ CLAUDE.md 로드 (입력 토큰, 매 턴)
  └─ 대화 기록 전체 (입력 토큰, 매 턴 누적)

에이전트 1턴
  └─ 사용자 메시지 → 입력
  └─ Claude 응답 (텍스트) → 출력
  └─ tool_use (예: Bash 호출) → 출력
  └─ tool_result (예: git log 출력 전체) → 입력
  └─ Claude 응답 (다음 판단) → 출력
```

### 가장 큰 비용 발생 원인

1. **누적 대화 기록**: 대화가 길어질수록 매 턴 입력 토큰이 선형 증가
2. **verbose tool 출력**: `git log --oneline -100` → 수천 토큰이 context에 진입
3. **대형 파일 Read**: 1000줄 파일을 Read하면 전체가 입력 토큰
4. **CLAUDE.md 길이**: 매 세션 자동 로드, 길수록 고정 비용 증가

---

## 3. 프롬프트 캐시 (Prompt Cache)

Anthropic은 대화 prefix를 자동 캐싱합니다 (TTL: 5분).

```
캐시 히트 조건: 동일한 prefix (system prompt + 이전 기록 앞부분)
캐시 히트 효과: 캐싱된 토큰 비용 90% 절감
```

**for_our_love에 주는 시사점:**
- CLAUDE.md는 항상 첫 번째 = 캐시 히트 가능성 높음 → 압축하면 캐시 절감 효율도 올라감
- 대화 중반부터는 캐시 히트율 낮아짐 → 이때 `/compact`가 효과적

---

## 4. Sub-agent의 토큰 효율

Claude Code에서 Agent를 spawn하면:
- 부모 대화 기록 없이 **새 context로 시작** → 누적 기록 없음
- 단점: 부모가 이미 읽은 파일을 sub-agent도 다시 읽어야 함

**최적 활용 패턴:**
- 독립적이고 context가 무거운 작업 → sub-agent
- 이미 context에 있는 정보를 활용하는 작업 → 직접 처리

---

## 5. for_our_love 최적화 매핑

| 문제 | 원인 | for_our_love 대응 |
|------|------|------------------|
| tool 출력이 너무 길다 | verbose CLI 출력 → context 진입 | RTK 필터링 |
| 문서를 매번 다 읽는다 | Read 전체 파일 | _AI참고/ 압축본 + CLAUDE.md 라우팅 |
| CLAUDE.md가 무겁다 | 매 세션 전체 로드 | 핵심 원칙만 유지, 상세는 docs로 분리 |
| Obsidian vault 전체 로드 | MCP API가 너무 많은 파일 전송 | vault-config.json → Grep → 필요한 파일만 Read |
| 대화 기록 누적 | 장기 세션 | /compact 주기적 실행 (Claude Code 내장) |

---

## 6. AWS 로컬 테스트 접근법 비교

EC2+PEM 기반 프로젝트에서 "로컬 테스트"를 구현하는 방법들과 동작 원리:

| 방법 | 원리 | 적합한 상황 | 난이도 |
|------|------|------------|--------|
| **Docker Compose** (이 프로젝트) | EC2 위의 서비스(DB, Redis 등)를 컨테이너로 동일하게 실행 | EC2에 PostgreSQL, Redis 등 서비스가 있는 경우 | 낮음 |
| **LocalStack** | AWS API(S3, DynamoDB, Lambda 등)를 로컬에서 에뮬레이션 | 서버리스, S3/DynamoDB 중심 아키텍처 | 중간 |
| **AWS Profiles** | `~/.aws/credentials`에 여러 profile 등록, `AWS_PROFILE` 환경변수로 전환 | 자격증명만 다른 동일 구조(dev/staging/prod) | 낮음 |
| **Moto (Python)** | 테스트 코드 내에서 AWS 서비스를 mock (boto3 호출을 가로챔) | 단위 테스트에서 실제 AWS 없이 boto3 코드 검증 | 중간 |
| **SAM Local** | Lambda + API Gateway를 로컬에서 실행 | 서버리스 Lambda 중심 아키텍처 | 중간 |
| **Testcontainers** | 테스트 실행 시 실제 컨테이너(PostgreSQL 등)를 자동 spin-up/teardown | 통합 테스트, 격리된 DB 환경이 필요한 경우 | 높음 |

**EC2+PEM 구조에서 Docker Compose가 최적인 이유**:
EC2에서 돌아가는 것은 AWS API가 아니라 "EC2 위의 서비스(PostgreSQL, Redis, Nginx 등)".
LocalStack은 AWS API를 에뮬레이션하지만, EC2에서 실행 중인 PostgreSQL을 에뮬레이션하지는 않음.
→ "EC2의 서비스 = Docker 컨테이너"로 1:1 대응하는 Docker Compose가 가장 직관적.

## 7. 더 개선하고 싶다면

- **Tool 결과 길이 제한**: Claude Code `settings.json`의 `maxFileSize` 등 설정 확인
- **Thinking 예산**: API 직접 호출 시 `budget_tokens` 파라미터로 제어
- **Context window 지표**: Claude Code `/status` 명령으로 현재 사용량 확인 가능
