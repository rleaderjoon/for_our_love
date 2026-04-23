# Attribution — 출처 명시

이 프로젝트에 포함된 아이디어와 도구의 원본 출처입니다.
순수한 창작물이 아니며, 기존 작업을 조합·정리한 것입니다.

---

## 1. Karpathy 원칙 (CLAUDE.md 행동 지침)

- **원본 아이디어**: Andrej Karpathy (OpenAI 공동창업자, Tesla AI 前 디렉터)
  - "Think before coding", "Simplicity first" 등의 소프트웨어 철학
  - 참고: https://karpathy.ai / https://x.com/karpathy
- **이 프로젝트에서 적용된 버전 출처**: `rleaderjoon/Understand-Investment` 의 `CLAUDE.md`
  - 원본을 한국어로 재구성 + Claude Code 지시사항 형식으로 편집

## 2. /compress (Caveman 압축)

- **원본**: Anthropic Claude Code 내장 `/compress` skill
  - Claude Code CLI에 포함된 기능으로, 파일을 caveman 스타일로 재작성
  - 참고: https://docs.anthropic.com/claude-code
- **이 프로젝트에서**: `compress_all.ps1` 스크립트로 자동화 + `_AI참고/` 폴더 구조 패턴 제안

## 3. Vault-Finder (Obsidian 직접 읽기)

- **원본 아이디어**: context-mode MCP 의 RAG 원리 (필요한 청크만 context에 로드)
  - Claude Code MCP 생태계 도구에서 영감
- **이 프로젝트에서**: MCP 서버 없이 직접 파일시스템 접근으로 동일 효과 구현
  - `scripts/vault-finder.ps1` — Obsidian vault 경로 탐색 및 저장
  - CLAUDE.md 지침으로 Claude가 vault-config.json → Grep → Read 패턴 사용

---

## 라이선스 관련

각 도구의 라이선스는 원본 저장소를 확인하세요.
이 프로젝트 자체(조합·문서화 작업)는 팀 내부 사용 목적입니다.
