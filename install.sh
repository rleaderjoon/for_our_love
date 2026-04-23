#!/bin/bash
# for_our_love — Mac/Linux 설치 스크립트
# 사용법: chmod +x install.sh && ./install.sh
# 출처: rleaderjoon/for_our_love

ROOT="$(cd "$(dirname "$0")" && pwd)"
STEP=0; TOTAL=4

step() { STEP=$((STEP+1)); echo "[$STEP/$TOTAL] $1"; }
ok()   { echo "  OK  $1"; }
warn() { echo "  !!  $1"; }
fail() { echo "  XX  $1"; exit 1; }

# ─── 1. Claude Code 확인 ────────────────────────────────────
step "Claude Code 확인"
if ! command -v claude &>/dev/null; then
    fail "Claude Code CLI가 없습니다. https://claude.ai/code 설치 후 재실행."
fi
ok "Claude Code 발견"

# ─── 2. Obsidian vault 탐색 ──────────────────────────────────
step "Obsidian vault 탐색"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OBSIDIAN_JSON="$HOME/Library/Application Support/obsidian/obsidian.json"
else
    OBSIDIAN_JSON="$HOME/.config/obsidian/obsidian.json"
fi

if [[ -f "$OBSIDIAN_JSON" ]]; then
    python3 -c "
import json, os, sys
with open('$OBSIDIAN_JSON') as f:
    data = json.load(f)
vaults = [{'name': os.path.basename(v['path']), 'path': v['path']}
          for v in data.get('vaults', {}).values()
          if os.path.exists(v.get('path', ''))]
out = {'generated': __import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
       'vault_count': len(vaults), 'vaults': vaults}
with open('$ROOT/vault-config.json', 'w') as f:
    json.dump(out, f, indent=2, ensure_ascii=False)
for v in vaults:
    print(f'    - {v[\"name\"]}: {v[\"path\"]}')
print(f'  발견된 vault: {len(vaults)}개')
"
else
    warn "Obsidian이 없거나 vault가 없습니다. 스킵."
fi

# ─── 3. CLAUDE.md 설정 ────────────────────────────────────────
step "CLAUDE.md 설정"
MARKER="# [for_our_love]"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
TEMPLATE="$ROOT/templates/CLAUDE.md"
APPEND="$ROOT/templates/claude-append.md"

if [[ ! -f "$GLOBAL_CLAUDE" ]]; then
    mkdir -p "$(dirname "$GLOBAL_CLAUDE")"
    cp "$TEMPLATE" "$GLOBAL_CLAUDE"
    ok "~/.claude/CLAUDE.md 생성 (템플릿에서)"
elif ! grep -qF "$MARKER" "$GLOBAL_CLAUDE"; then
    printf '\n---\n' >> "$GLOBAL_CLAUDE"
    cat "$APPEND" >> "$GLOBAL_CLAUDE"
    ok "~/.claude/CLAUDE.md 에 for_our_love 섹션 추가"
else
    ok "~/.claude/CLAUDE.md 이미 설정됨. 스킵."
fi

# ─── 4. compress_all 실행 ─────────────────────────────────────
step "문서 압축"
python3 "$ROOT/scripts/compress_all.py" "$ROOT" 2>/dev/null || \
    warn "Python3 없음. 문서 압축 스킵. (선택 사항)"

echo ""
echo "=== 설치 완료 ==="
[[ -f "$ROOT/vault-config.json" ]] && echo "  vault-config.json  — Obsidian vault 등록됨"
[[ -d "$ROOT/_AI참고" ]]           && echo "  _AI참고/           — 압축 문서 생성됨"
echo "  CLAUDE.md 행동 지침 적용됨"
