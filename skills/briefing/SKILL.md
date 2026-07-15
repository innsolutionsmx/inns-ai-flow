---
name: briefing
description: >
  Briefing de cierre de un batch/tanda de trabajo. Actívalo cuando el usuario acepte
  la oferta de briefing tras cerrar un batch (merge a dev), diga "hacé el briefing",
  "cerremos con briefing", "briefing de cierre", o invoque /briefing. Produce tres cosas:
  (1) qué se hizo y por qué, (2) checklist de QA MANUAL para probar en la UI,
  (3) handoff en TEXTO PLANO copiable para la próxima sesión + guardado en engram.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- El usuario aceptó la oferta de briefing que dispara el hook `briefing-detect.sh` al cerrar un batch.
- Se cerró una unidad de trabajo (batch de un PRD, feature, fix) y hay que dejarla documentada + lista para retomar.
- El usuario pide explícitamente un briefing / handoff de sesión.

> **No es** `mem_session_summary` genérico. Esto es un cierre orientado a: entender qué se hizo, poder hacer QA a mano, y arrancar la próxima sesión sin re-investigar.

## Critical Patterns (reglas duras)

- **Reunir contexto REAL antes de escribir** — nunca de memoria. Leé git (commits/merge del batch), la task list, engram reciente y el diff. Si un dato no lo verificás, no lo afirmás.
- **Tres entregables SIEMPRE, en este orden**: Briefing → QA manual → Handoff.
- **QA = manual (humano en la UI).** Los tests automáticos (Pest/Playwright) ya los corre Claude durante el batch; acá NO se listan comandos. Se listan pasos clickeables: qué pantalla, qué hacer, qué se espera ver.
- **Handoff = doble destino**: (a) guardar en engram con `mem_save` (topic_key estable del PRD/feature) para recuperación cross-sesión, y (b) imprimir en un bloque de **texto plano copiable** (code fence) que el usuario pega al arrancar una sesión nueva.
- El handoff copiable debe ser **auto-contenido**: al pegarlo, Claude entiende a la primera qué se hizo, qué sigue y cómo arrancar. Incluí estado, próximo paso, rama base y punteros (topic_key engram, archivos clave).
- No inventes pasos de QA para código que no toca UI (jobs, migraciones, backend puro): en ese caso el QA describe cómo verificar el efecto (dato en DB, log, endpoint), no clicks.

## Proceso

1. **Reunir contexto** (ver Commands): commits del batch, merge a dev, task list, últimas observaciones de engram, diff `--stat`.
2. **Briefing** — qué se hizo y POR QUÉ. Por cada cambio: el problema/bug, la decisión tomada, dónde (archivos). Breve, denso, sin relleno.
3. **QA manual** — checklist numerado. Por ítem: precondición → acción en la UI → resultado esperado. Cubrí el happy path y al menos un caso de borde/seguridad del batch.
4. **Handoff** — redactá el bloque copiable, guardalo en engram, e imprimilo. Ver plantilla.

## Plantilla del Handoff (texto plano copiable)

```
Continuamos: {PRD/feature — nombre corto}.
Estado: {qué está cerrado hasta ahora, ej. "Batches 0-N mergeados a dev"}.
Recién cerrado: {este batch — 1 línea}.
Sigue: {próximo paso concreto — ej. "Batch N+1: <qué> (bugs X,Y)"}.
Rama base: dev. Arrancá con la skill iniciar-trabajo-git.
Contexto: engram topic_key "{key}". Archivos clave: {rutas}.
Decisiones abiertas: {si hay una decisión de negocio/técnica pendiente, nombrala; si no, "ninguna"}.
```

## Commands

```bash
# Contexto del batch recién cerrado
git log --oneline -8
git show --stat HEAD            # el merge --no-ff a dev
git diff --stat HEAD~1 HEAD     # archivos del batch

# Estado del tablero (si se usó TaskCreate)
# (revisar la task list de la sesión)
```

```
# Guardar el handoff en engram (herramienta, no bash):
mem_save(title, type: "session_summary", scope: "project",
         topic_key: "{prd}/handoff", content: "<el handoff completo>")
```

## Resources

- Cierre de git (merge a dev) que dispara este briefing: skill `guardar-cambios-git`.
- Apertura de la próxima sesión: skill `iniciar-trabajo-git`.
