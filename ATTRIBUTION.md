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
- **이 프로젝트에서**: skill 정의 규칙을 문서화 + `_AI참고/` 폴더 구조 패턴 제안

## 3. RTK (Rust Token Killer)

- **원본**: RTK AI Labs
  - CLI 도구로 명령어 출력을 필터링해 Claude context 진입 토큰 절감
  - 참고: https://github.com/rtk-ai/rtk
- **이 프로젝트에서**: 설치 가이드 + CLAUDE.md 연동 방법 문서화

## 4. context-mode MCP

- **원본**: context-mode MCP 서버
  - 문서를 벡터 인덱싱해 시맨틱 검색으로 필요한 청크만 context에 로드 (RAG)
  - Claude Code MCP 생태계 도구
- **이 프로젝트에서**: 설치 가이드 + 사용 패턴 문서화

---

## 라이선스 관련

각 도구의 라이선스는 원본 저장소를 확인하세요.
이 프로젝트 자체(조합·문서화 작업)는 팀 내부 사용 목적입니다.
