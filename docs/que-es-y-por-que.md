# Qué es inns-ai-flow y por qué existe

## El problema que lo originó

Antes del plugin, el workflow de la casa (skills de gitflow, hooks de guardia, la
convención de CLAUDE.md + carpeta `ai/`) vivía **copiado a mano en cada proyecto**.
El inventario del 2026-07-15 sobre 11 proyectos encontró el costo real de eso:

- `guardar-cambios-git` estaba en 7 proyectos con **2 versiones divergentes** — varios
  proyectos corrían la v1.0 vieja sin saber que existía una v1.2 mejor.
- `seo-frontend` y `ux-polish`: también partidas en 2 versiones cada una.
- La convención de carpeta estaba dividida: 4 proyectos con `ai/`, 3 con `ia/`.
- Cada mejora había que copiarla proyecto por proyecto; en la práctica, nadie lo hacía.

## Qué resuelve

**Un solo lugar para el workflow.** Las skills y hooks viven en ESTE repo. Una mejora
acá + un bump de versión + push a `main` = todos los proyectos la reciben automático
en su próxima sesión (ver `actualizacion.md`). Los proyectos dejan de TENER copias y
pasan a REFERENCIAR una versión.

## Qué NO resuelve (a propósito)

- **Skills de stack Laravel** (`crear-proyecto`, `setup-proyecto`, `arrancar-desarrollo`,
  `landing-porting`): son de "cómo se arma un Laravel", no de "cómo trabaja el equipo".
  Candidatas a un futuro plugin `inns-laravel`.
- **Diseño frontend**: ese rol es de [design-forge](https://github.com/innsolutionsmx/design-forge)
  (pipeline de diseño con Impeccable como cerebro). `ux-polish` quedó deprecada a favor
  de ese ecosistema.
- **Contenido del proyecto**: CLAUDE.md, `ai/context/`, `progreso-actual.md` son
  archivos DEL proyecto — el plugin no puede inyectarlos; el comando `bootstrap` los
  crea una vez y de ahí son del repo.

## Cómo funciona por dentro

Un plugin de Claude Code es un paquete versionado que se instala desde un marketplace
(este mismo repo). Al habilitarse en un proyecto aporta tres tipos de piezas:

1. **Hooks** (`hooks/hooks.json`) — se cablean SOLOS, sin tocar el settings del
   proyecto. Al abrir sesión: `git-session-status` reporta la rama y el estado del
   árbol, y `progreso-status` inyecta la sección "Última actualización" de
   `progreso-actual.md` (el agente arranca sabiendo dónde quedó el trabajo, sin
   depender de que lea prosa). Durante la sesión: `git-guard` **bloquea** cualquier
   Edit/Write si estás parado en `main` o `dev` — la regla de oro deja de ser un
   consejo y pasa a ser un candado. Tras un push a `dev`: `briefing-detect` ofrece el
   briefing de cierre.

2. **Skills** (`skills/`) — se auto-invocan por contexto o se llaman con
   `/inns-ai-flow:<skill>`. Cubren el ciclo completo de una tarea:
   `iniciar-trabajo-git` (abrir rama bien parada) → trabajo normal →
   `guardar-cambios-git` (commit, tests, integrar a dev, inventario de pendientes) →
   `briefing` (cierre de batch con QA y handoff).

3. **Comando** (`/inns-ai-flow:bootstrap`) — crea en el proyecto lo que el plugin no
   puede inyectar: carpeta `ai/context/` con `progreso-actual.md`, CLAUDE.md desde el
   template canónico, settings declarativo. En proyectos legacy además ADELGAZA el
   CLAUDE.md (remueve la convención duplicada) y detecta copias viejas de skills/hooks.

Principio de diseño detrás de todo: **lo determinístico va en hooks, el juicio va en
skills, y la prosa solo para lo que ninguna de las dos puede hacer.** Un párrafo en
CLAUDE.md se puede ignorar; un hook corre siempre.
