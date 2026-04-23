# for_our_love

Claude Code 토큰 절감 도구 모음. 팀원이 처음부터 삽질하지 않도록.

## 빠른 시작 (3단계)

**Windows:**
```powershell
.\install.ps1
```

**Mac/Linux:**
```bash
chmod +x install.sh && ./install.sh
```

그 다음 `templates/CLAUDE.md`를 프로젝트 루트에 복사하고 내용 커스터마이징.

---

## 포함된 도구

| # | 도구 | 절감 효과 | 출처 |
|---|------|----------|------|
| 1 | Karpathy 원칙 (CLAUDE.md) | 불필요한 작업 방지 | `ATTRIBUTION.md` |
| 2 | /compress | 참조 문서 40-60% 압축 | `ATTRIBUTION.md` |
| 3 | RTK | 명령어 출력 60-90% 압축 | `ATTRIBUTION.md` |
| 4 | context-mode MCP | 필요한 청크만 검색(RAG) | `ATTRIBUTION.md` |

각 도구 원리 → `docs/how_it_works.md`

---

## 출처

이 프로젝트는 기존 오픈소스 도구들을 조합한 것입니다. → `ATTRIBUTION.md`
