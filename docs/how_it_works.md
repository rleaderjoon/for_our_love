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

## 2. /compress — LLM이 파일 직접 재작성

**원리**: Claude가 참조 문서를 압축 버전으로 재작성 → 다음 대화에서 읽을 때 토큰 절감

```
원본 파일 → /compress → 40-60% 압축본 (_AI참고/ 폴더)
                              ↓
                    CLAUDE.md 라우팅에서 압축본을 읽도록 설정
```

- 전처리 없음. Claude 자신이 변환.
- 원본은 보존, `_AI참고/` 폴더에 압축본 생성.
- CLAUDE.md 라우팅 테이블을 압축본 경로로 수정.

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

## 3. RTK — Shell 출력 필터링

**원리**: CLI 바이너리가 명령어 출력을 가로채 핵심만 남김

```
rtk git log
  → git log 실행
  → 출력 파이프 필터
  → 핵심만 Claude context 진입
```

- **두 레이어**:
  1. CLAUDE.md에 "rtk 써라" 주입 → Claude가 rtk 명령 선택
  2. rtk 바이너리가 실제 필터링 수행
- Windows에서는 hook 자동주입 불가 → Claude가 의식적으로 `rtk` 붙여야 함.
- **절감**: git/npm/test 출력 60-90%.

---

## 4. context-mode MCP — RAG (시맨틱 검색)

**원리**: 문서를 벡터 인덱싱 → 필요한 청크만 검색해서 context 로드

```
ctx_index: 문서들 → 벡터 DB 생성
ctx_search: "쿼리" → 관련 청크만 pull → context 진입
```

- 전체 파일 읽지 않고 **관련 부분만** 가져옴.
- 가장 정교한 방식. MCP 서버 백엔드 필요.
- **절감**: 대형 문서에서 필요한 10%만 읽기.

---

## 요약 비교

| 도구 | 원리 | 전처리 | 최적 용도 |
|------|------|--------|---------|
| Karpathy CLAUDE.md | 텍스트 instruction | 없음 | 행동 방향 설정 |
| /compress | LLM 파일 재작성 | 없음 | 자주 읽는 문서 |
| RTK | shell 출력 필터 | shell 레벨 | git/빌드/테스트 출력 |
| context-mode | 벡터 인덱스+검색 | MCP 서버 | 대형 문서 탐색 |
