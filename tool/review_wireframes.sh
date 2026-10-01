#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_dir="${EXCALIDRAW_SKILL_DIR:-$HOME/.agents/skills/excalidraw-use}"
validator="$skill_dir/scripts/validate_excalidraw.py"
renderer="$skill_dir/scripts/render_scene.py"
reviewer="$skill_dir/scripts/review_legibility.py"

for required in "$validator" "$renderer" "$reviewer"; do
  if [[ ! -f "$required" ]]; then
    printf 'Missing Excalidraw tool: %s\n' "$required" >&2
    printf 'Set EXCALIDRAW_SKILL_DIR to the installed excalidraw-use skill.\n' >&2
    exit 2
  fi
done

cd "$repo_dir"
python3 tool/gen_wireframes.py

scenes=(docs/design/*.excalidraw)
python3 "$validator" "${scenes[@]}"

for scene in "${scenes[@]}"; do
  python3 "$renderer" "$scene" --out "${scene%.excalidraw}.png"
done

python3 "$reviewer" "${scenes[@]}"
printf 'Reviewed %s editable scenes and 720p renders.\n' "${#scenes[@]}"
