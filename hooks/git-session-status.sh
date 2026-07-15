#!/usr/bin/env bash
# SessionStart — informa el estado del gitflow al iniciar la sesión.
# Solo lectura: no muta nada, solo agrega contexto.
set -euo pipefail

branch="$(git branch --show-current 2>/dev/null || true)"

# Fuera de un repo git → nada que reportar.
[ -z "${branch}" ] && exit 0

echo "Gitflow — estado al iniciar sesion:"
echo "  Rama actual: ${branch}"

if [ "${branch}" = "main" ] || [ "${branch}" = "dev" ]; then
  echo "  AVISO: estas en una rama protegida. Antes de modificar codigo, crea una rama de trabajo (skill iniciar-trabajo-git). El hook git-guard bloqueara cualquier Edit/Write hasta que lo hagas."
fi

dirty="$(git status --porcelain 2>/dev/null || true)"
if [ -n "${dirty}" ]; then
  echo "  Hay cambios sin commitear en el arbol de trabajo."
fi

exit 0
