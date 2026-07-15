# Referencia

## Skills

Se auto-invocan por contexto, o manualmente como `/inns-ai-flow:<nombre>`.

### `iniciar-trabajo-git`
- **Cuándo se activa**: arranque de una tarea, "nueva rama", "arranquemos", o cuando
  estás en `main`/`dev` y vas a editar (reforzada por el hook `git-guard`).
- **Qué hace**: te para en `dev` actualizado (`pull`) y crea la rama `{tipo}/{nombre}`
  con el prefijo Conventional correcto ANTES de tocar código.
- **Produce**: rama de trabajo lista; nunca se edita en ramas protegidas.

### `guardar-cambios-git`
- **Cuándo se activa**: cierre de tarea — "guardemos cambios", "integremos a dev".
- **Qué hace**: commit (Conventional Commits) → tests si el diff toca código (se
  omiten con diff solo-docs, anotándolo) → merge de la rama a `dev` → sincroniza
  local/remoto → limpia la rama → **inventario de pendientes** (ramas solo-locales,
  commits en `dev` no promovidos a `main`, ramas sin mergear, sync de permanentes).
- **Regla dura**: nada se integra en rojo; promoción a `main` solo si se pide explícito.

### `briefing`
- **Cuándo se activa**: cierre de batch — ofrecida automáticamente por
  `briefing-detect` tras un push a `dev`, o a pedido.
- **Qué hace**: resumen de qué se hizo y por qué, checklist de QA manual para la UI,
  handoff en texto plano copiable + guardado en memoria.
- **Produce**: continuidad — la próxima sesión (tuya o de un compañero) arranca con
  contexto.

### `seo-frontend`
- **Cuándo se activa**: trabajo en vistas públicas — meta tags, Open Graph, JSON-LD,
  canonical, sitemap, robots.txt, Core Web Vitals, accesibilidad.
- **Qué hace**: aplica el estándar SEO/a11y de la casa sobre la vista en cuestión.

## Hooks (se cablean solos vía `hooks/hooks.json`)

### `git-session-status.sh` — SessionStart
Reporta al abrir sesión: rama actual, aviso si es protegida, árbol sucio. Solo lectura.

### `progreso-status.sh` — SessionStart
Busca `ai/context/progreso-actual.md` (o `ia/`) e inyecta su sección "Última
actualización" como contexto: el agente arranca sabiendo dónde quedó el trabajo.
Si hay carpeta de contexto sin el archivo, sugiere `/inns-ai-flow:bootstrap`.

### `git-guard.sh` — PreToolUse (Edit|Write|MultiEdit|NotebookEdit)
**Bloquea** la edición si la rama del archivo es `main` o `dev` y explica cómo abrir
rama. Deriva la rama desde el directorio del ARCHIVO (correcto incluso con repos
anidados). Fuera de un repo git no interviene.

### `briefing-detect.sh` — PostToolUse (Bash)
Detecta `push origin dev` exitoso (ignora pushes rechazados) e inyecta el recordatorio
de ofrecer el briefing. No genera el briefing — eso es de la skill, si aceptás.

## Comandos

### `/inns-ai-flow:bootstrap`
Deja el proyecto con la convención completa. Crea (con MERGE, nunca overwrite):
`ai/context/` + `progreso-actual.md`, CLAUDE.md desde `templates/CLAUDE.template.md`
(solo contenido del proyecto), settings declarativo con `autoUpdate`. En proyectos
legacy: adelgaza CLAUDE.md y detecta copias viejas de skills/hooks (pide confirmación).

## Archivos del repo que no viajan al proyecto

| Pieza | Rol |
|-------|-----|
| `templates/CLAUDE.template.md` | Estructura canónica que usa bootstrap |
| `SETUP.md` | Instrucciones ejecutables por un agente para instalar el plugin |
| `docs/` | Esta documentación |
| `.claude/settings.json` | Dogfood: el repo se instala a sí mismo |
