#!/usr/bin/env bash
# PostToolUse (Bash) — detecta el CIERRE de un batch (push a dev) e inyecta un
# recordatorio para ofrecer un briefing de cierre.
#
# El hook NO genera el briefing: el harness no razona, solo corre este script e
# inyecta contexto. El trabajo (qué se hizo, QA, handoff) lo hace la skill `briefing`
# si el usuario acepta la oferta.
set -euo pipefail

payload="$(cat 2>/dev/null || true)"

# ¿El comando ejecutado fue un push a dev? (cierre de batch vía guardar-cambios-git,
# tanto Caso A merge de rama como Caso B commit directo a dev).
if printf '%s' "${payload}" | grep -Eq 'push[[:space:]]+origin[[:space:]]+dev'; then

  # No ofrecer si el push fue rechazado / falló: el batch no quedó realmente cerrado.
  if printf '%s' "${payload}" | grep -Eqi 'rejected|non-fast-forward|failed to push|error:'; then
    exit 0
  fi

  msg="Se detecto un push a dev (cierre de batch/tanda de trabajo). Preguntale al usuario si quiere un BRIEFING de cierre. Si acepta, ejecuta la skill briefing, que produce: (1) que se hizo y por que, (2) checklist de QA manual para probar en la UI, (3) handoff en texto plano copiable + guardado en engram para arrancar la proxima sesion con contexto. Si el usuario dice que no, no insistas."

  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "${msg}"
  exit 0
fi

exit 0
