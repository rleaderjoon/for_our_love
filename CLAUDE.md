# CLAUDE.md — for_our_love

> 이 프로젝트는 팀원용 Claude Code 토큰 절감 도구 모음입니다.
> 각 도구의 출처는 `ATTRIBUTION.md` 참조.

## 작업별 참조 파일

| 작업 유형 | 읽을 파일 |
|-----------|----------|
| 도구 원리 이해 | `docs/how_it_works.md` |
| 출처 확인 | `ATTRIBUTION.md` |
| 설치 스크립트 수정 | `install.ps1` / `install.sh` |
| CLAUDE.md 템플릿 수정 | `templates/CLAUDE.md` |

## 이 프로젝트의 목표

1. 팀원이 원클릭으로 4가지 토큰 절감 도구를 설치할 수 있게 한다.
2. 각 도구의 출처를 명확히 밝힌다.
3. Claude 튜닝 템플릿을 팀이 공유한다.

## TODO (다음 세션에서 작업할 것)

- [ ] RTK 정확한 설치 명령어 확인 후 install 스크립트 완성
- [ ] context-mode MCP 설치 명령어 확인 후 추가
- [ ] compress_all 자동화 스크립트 작성 (docs 폴더 전체 _AI참고/ 압축)
- [ ] 추가 튜닝 아이디어 논의 및 구현

## 행동 원칙

### 단순함 우선
문서와 스크립트는 팀원이 읽기 쉽게. 과한 추상화 금지.

### 외과적 변경
각 파일의 역할 범위를 벗어나지 말 것.
