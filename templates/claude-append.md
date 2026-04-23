# [for_our_love]
<!-- rleaderjoon/for_our_love 설치 시 자동 추가 -->

## Obsidian Vault 읽기 규칙

vault-config.json이 존재할 때:
1. vault-config.json을 읽어 vault 경로와 파일 수 확인
2. Grep으로 필요한 파일만 검색 (쿼리 → 파일명 → Read)
3. vault 전체를 한 번에 로드하는 것은 금지
4. 여러 vault에 동시에 접근할 때도 동일 규칙 적용

## 문서 읽기 우선순위

_AI참고/ 폴더가 있으면 원본 대신 압축본을 우선 읽을 것:
- 원본: docs/API.md → 먼저 확인: _AI참고/docs/API.md
- 압축본이 없으면 원본 읽기

## CLI 출력 compact 규칙

토큰 절감을 위해 항상 compact 옵션 사용:
- git log → `git log --oneline -20`
- git diff → `git diff --stat` (상세 필요 시 특정 파일만)
- git status → `git status -s`
- npm/pnpm install → 마지막 15줄만 확인
- docker ps → `docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"`
- 빌드 출력이 길면 마지막 20줄만 확인 (Select-Object -Last 20)
