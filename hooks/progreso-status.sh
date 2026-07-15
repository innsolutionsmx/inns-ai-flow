#!/usr/bin/env bash
# SessionStart — inyecta el estado de progreso-actual.md (convención inns-ai-flow).
# Convierte la regla "leé progreso-actual PRIMERO" de prosa en CLAUDE.md a contexto
# inyectado determinísticamente: el agente arranca ya sabiendo dónde quedó el trabajo.
set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

for f in "ai/context/progreso-actual.md" "ia/context/progreso-actual.md"; do
  if [ -f "${f}" ]; then
    echo "Convencion inns-ai-flow: ${f} es el source of truth de 'donde quedamos'."
    echo "Leelo COMPLETO antes de la primera tarea real, y actualizalo al cerrar cada sesion o batch (se sincroniza entre maquinas y companeros via git)."
    echo ""
    echo "--- Ultima actualizacion registrada ---"
    awk '/^## Última actualización/{flag=1; next} /^## /{if (flag) exit} flag' "${f}" | head -20
    exit 0
  fi
done

# Sin progreso-actual.md: si existe la convención a medias, avisar; si no, silencio.
if [ -d "ai/context" ] || [ -d "ia/context" ]; then
  echo "Convencion inns-ai-flow: existe carpeta de contexto AI pero falta progreso-actual.md. Sugerile al usuario correr /inns-ai-flow:bootstrap para completar la convencion."
fi

exit 0
