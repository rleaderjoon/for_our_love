# CLAUDE.md — for_our_love

> 이 프로젝트는 팀원용 Claude Code 토큰 절감 도구 모음입니다.
> 각 도구의 출처는 `ATTRIBUTION.md` 참조.

## 작업별 참조 파일

| 작업 유형 | 읽을 파일 |
|-----------|----------|
| 도구 원리 이해 | `docs/how_it_works.md` |
| 출처 확인 | `ATTRIBUTION.md` |
| 설치 스크립트 수정 | `install.ps1` |
| CLAUDE.md 템플릿 수정 | `templates/CLAUDE.md` |
| CLAUDE.md 추가 섹션 수정 | `templates/claude-append.md` |
| vault 읽기 스크립트 | `scripts/vault-finder.ps1` |
| 문서 압축 스크립트 | `scripts/compress_all.ps1` |
| 토큰 구조 이해 | `suggest.md` |

## 이 프로젝트의 목표

토큰 수를 줄이면서 코딩 완성도를 높이고, 불필요한 코드 작성을 방지하며, 장기 기억과 통신 과정의 토큰을 아끼는 올인원 설치 도구.

1. 팀원이 `.\install.ps1` 한 번으로 모든 도구를 설치할 수 있게 한다.
2. 각 도구의 출처를 명확히 밝힌다.
3. Claude 튜닝 템플릿을 팀이 공유한다.

## 문서 읽기 우선순위

_AI참고/ 압축본이 있으면 원본 대신 압축본을 우선 읽을 것:
- 예: docs/how_it_works.md → 먼저 _AI참고/docs/how_it_works.md 확인

## 행동 원칙

### 단순함 우선
문서와 스크립트는 팀원이 읽기 쉽게. 과한 추상화 금지.

### 외과적 변경
각 파일의 역할 범위를 벗어나지 말 것.
