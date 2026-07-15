#!/usr/bin/env bash
# PreToolUse guard — bloquea Edit/Write/MultiEdit/NotebookEdit cuando estás en main o dev.
# Regla de oro del gitflow: nunca se modifica directo en main/dev.
set -euo pipefail

# Leemos el payload de PreToolUse (JSON por stdin) para derivar la rama desde el repo del
# ARCHIVO que se va a editar, no del cwd de la sesión. Así el guard es correcto aunque el
# archivo viva en un sub-repo (submódulo / repo anidado) distinto del cwd de la sesión.
payload="$(cat 2>/dev/null || true)"
file_path="$(printf '%s' "${payload}" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1 || true)"

dir="$(pwd)"
if [ -n "${file_path}" ]; then
  d="$(dirname "${file_path}")"
  [ -d "${d}" ] && dir="${d}"
fi

branch="$(git -C "${dir}" branch --show-current 2>/dev/null || true)"

# Fuera de un repo git, o no se pudo determinar la rama → no bloqueamos.
[ -z "${branch}" ] && exit 0

if [ "${branch}" = "main" ] || [ "${branch}" = "dev" ]; then
  msg="Gitflow: estas en la rama protegida '${branch}'. La regla de oro prohibe modificar directo en main/dev. Crea una rama de trabajo antes de editar: git checkout dev && git pull origin dev && git checkout -b feat/nombre  (o invoca la skill iniciar-trabajo-git). Elegi el prefijo Conventional segun el cambio: feat/fix/chore/docs/refactor/test/perf/style/ci/build."
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "${msg}"
  exit 0
fi

exit 0
