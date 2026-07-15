# Casos de uso

Escenarios reales, paso a paso. En todos, "el agente" es Claude Code con el plugin
habilitado en el proyecto.

## 1. Arranco una tarea nueva

1. Abrís sesión → `git-session-status` te muestra rama y estado; `progreso-status`
   te inyecta dónde quedó el trabajo.
2. Pedís la tarea ("agreguemos X"). Si estás parado en `main`/`dev`, `git-guard`
   bloquea la primera edición y el agente invoca `iniciar-trabajo-git`: te para en
   `dev` actualizado y crea `feat/x` (prefijo Conventional según el cambio).
3. Trabajás normal — el resto del pipeline no interviene hasta el cierre.

## 2. Cierro una tarea

1. Decís "guardemos los cambios" (o el agente lo propone al terminar).
2. `guardar-cambios-git`: commitea con Conventional Commits, corre la suite de tests
   si el diff toca código (los salta si es solo docs), integra la rama a `dev`,
   sincroniza remotos, limpia la rama, y te reporta el **inventario de pendientes**:
   qué quedó solo en local, qué está en `dev` pero no en `main`, para que nunca creas
   que algo está en producción cuando no lo está.
3. Promoción a `main`: SOLO si la pedís explícito.

## 3. Cierro un batch de trabajo

1. Tras el push a `dev`, `briefing-detect` lo detecta y el agente te ofrece un briefing.
2. Si aceptás, la skill `briefing` produce: qué se hizo y por qué, checklist de QA
   manual para probar en la UI, y un handoff copiable + guardado en memoria para
   arrancar la próxima sesión (o para pasarle a un compañero).
3. `progreso-actual.md` se actualiza — tu otra máquina y tu equipo lo reciben con git.

## 4. Proyecto nuevo desde cero

1. Instalás el plugin (ver README o pegale el SETUP.md a Claude).
2. Corrés `/inns-ai-flow:bootstrap`: crea `ai/context/` con `progreso-actual.md`,
   CLAUDE.md desde el template canónico (solo contenido del proyecto — la convención
   ya viene en el plugin), y el settings declarativo.
3. Desde ese momento el proyecto tiene el workflow completo de la casa.

## 5. Un compañero se suma a un proyecto existente

1. Clona el repo y abre Claude Code.
2. Acepta el diálogo de **Trust** → el marketplace declarado en `.claude/settings.json`
   se instala y el plugin se habilita solo (si el prompt no aparece, fallback manual
   en `docs/actualizacion.md`).
3. Su primera sesión ya arranca con los hooks activos y el estado de
   `progreso-actual.md` inyectado. No necesita que nadie le explique el workflow:
   el workflow lo va llevando.

## 6. Mejoro el workflow del equipo

1. El cambio se hace en ESTE repo (nunca en la copia de un proyecto — ya no hay copias).
2. Rama → merge a `dev` → cuando el owner decide release: bump de versión + merge a
   `main` (detalle en `desarrollo-y-releases.md`).
3. Todos los proyectos con `autoUpdate: true` reciben la versión nueva en su próxima
   sesión. Nadie copia nada.

## 7. Proyecto legacy con copias viejas del workflow

1. Pegale el SETUP.md a Claude en ese proyecto.
2. El agente instala el plugin, detecta las copias legacy (skills/hooks duplicados y
   su cableado en settings), te pide confirmación para removerlas (si quedan, los
   hooks corren DOBLE), barre referencias stale en docs, y `bootstrap` adelgaza el
   CLAUDE.md.
